#!/usr/bin/env bash
# /etc/nixos/scripts/manage-hardware.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DETECT_SCRIPT="$SCRIPT_DIR/detect-hardware.sh"

# ═══════════════════════════════════════════════════════════
# 颜色定义
# ═══════════════════════════════════════════════════════════
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ═══════════════════════════════════════════════════════════
# 函数定义
# ═══════════════════════════════════════════════════════════
print_header() {
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC} $1"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

show_hardware_info() {
    print_header "Hardware Detection"
    
    if [ ! -x "$DETECT_SCRIPT" ]; then
        print_error "Detection script not found or not executable"
        return 1
    fi
    
    "$DETECT_SCRIPT" json | jq .
}

check_modules() {
    print_header "Checking Module Availability"
    
    local cpu_model=$("$DETECT_SCRIPT" cpu)
    local gpu_model=$("$DETECT_SCRIPT" gpu)
    
    print_success "Detected CPU: $cpu_model"
    print_success "Detected GPU: $gpu_model"
    
    echo ""
    echo "CPU Module:"
    if [ -f "/etc/nixos/modules/hardware/cpu/${cpu_model}.nix" ]; then
        print_success "  ✓ Module exists: /etc/nixos/modules/hardware/cpu/${cpu_model}.nix"
    else
        print_warning "  ✗ Module not found: /etc/nixos/modules/hardware/cpu/${cpu_model}.nix"
    fi
    
    echo ""
    echo "GPU Module:"
    if [ -f "/etc/nixos/modules/hardware/gpu/${gpu_model}.nix" ]; then
        print_success "  ✓ Module exists: /etc/nixos/modules/hardware/gpu/${gpu_model}.nix"
    else
        print_warning "  ✗ Module not found: /etc/nixos/modules/hardware/gpu/${gpu_model}.nix"
    fi
}

rebuild_system() {
    print_header "Rebuilding System with Auto-Detected Hardware"
    
    echo "Running hardware detection..."
    show_hardware_info
    
    echo ""
    echo "Building system configuration..."
    sudo nixos-rebuild switch --flake /etc/nixos#nixos --show-trace
    
    if [ $? -eq 0 ]; then
        print_success "System rebuilt successfully!"
    else
        print_error "System rebuild failed!"
        return 1
    fi
}

test_build() {
    print_header "Testing Build (Dry Run)"
    
    echo "This will check if the configuration builds without applying it."
    echo ""
    
    sudo nixos-rebuild build --flake /etc/nixos#nixos --show-trace
    
    if [ $? -eq 0 ]; then
        print_success "Build test passed!"
    else
        print_error "Build test failed!"
        return 1
    fi
}

show_status() {
    print_header "Current Status"
    
    echo "Hostname: $(hostname)"
    echo ""
    
    if [ -f /etc/nixos/.hardware-detected.json ]; then
        echo "Last detected hardware:"
        cat /etc/nixos/.hardware-detected.json | jq .
    else
        echo "No previous detection found."
    fi
    
    echo ""
    echo "Available CPU modules:"
    ls -1 /etc/nixos/modules/hardware/cpu/*.nix 2>/dev/null | sed 's|.*/||' || echo "  (none)"
    
    echo ""
    echo "Available GPU modules:"
    ls -1 /etc/nixos/modules/hardware/gpu/*.nix 2>/dev/null | sed 's|.*/||' || echo "  (none)"
}

clean_cache() {
    print_header "Cleaning Cache"
    
    sudo rm -f /etc/nixos/.hardware-detected.json
    sudo nix-collect-garbage -d
    
    print_success "Cache cleaned!"
}

show_help() {
    cat <<HELP
${BLUE}NixOS Hardware Management Tool${NC}

${GREEN}Usage:${NC} $0 <command>

${GREEN}Commands:${NC}
  detect      Show detected hardware information
  check       Check if corresponding modules exist
  rebuild     Rebuild system with auto-detected hardware
  test        Test build without applying changes
  status      Show current status and available modules
  clean       Clean cache and detected hardware info
  help        Show this help message

${GREEN}Examples:${NC}
  $0 detect   # Show what hardware is detected
  $0 check    # Verify modules exist for detected hardware
  $0 rebuild  # Apply configuration and rebuild system
  $0 test     # Test if build succeeds without applying

${GREEN}Workflow:${NC}
  1. Run '$0 detect' to see detected hardware
  2. Run '$0 check' to verify modules exist
  3. Run '$0 test' to test build
  4. Run '$0 rebuild' to apply changes

HELP
}

# ═══════════════════════════════════════════════════════════
# 主程序
# ═══════════════════════════════════════════════════════════
main() {
    local cmd="${1:-help}"
    
    case "$cmd" in
        detect|info)
            show_hardware_info
            ;;
        check|verify)
            check_modules
            ;;
        rebuild|apply)
            rebuild_system
            ;;
        test|dry-run)
            test_build
            ;;
        status)
            show_status
            ;;
        clean)
            clean_cache
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "Unknown command: $cmd"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

main "$@"