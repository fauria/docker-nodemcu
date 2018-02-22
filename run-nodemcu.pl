#!/usr/bin/perl -w
use strict;
use Term::ANSIColor qw(:constants);

my $user_config = 'app/include/user_modules.h';
open DEFAULT_CONFIG, '<'.$user_config or die('Missing firmware source code');

# Build lists of supported and enabled modules
my @available_modules;
my @enabled_modules;
while (<DEFAULT_CONFIG>) {
    if (m/(.+)define LUA_USE_MODULES_(\w+)/) {
        my $module_name = $2;
        my $is_comment = $1 =~ m/^\#/;
        push @available_modules, $module_name;
        push @enabled_modules, $module_name if $is_comment;
    }
}

# Custom modules passed as env vars
my @custom_modules;
foreach my $key (keys %ENV) {
    push @custom_modules, $2 if ($key =~ m/^(ENABLE_)(.*)$/);
}

# Override default list there are custom modules
@enabled_modules = @custom_modules if scalar(@custom_modules);

# Include only existing modules
my %enabled_modules = map {
    my $m = $_;
    if (grep {$m eq $_} @enabled_modules) {
        $_ => 1
    } else {
        $_ => 0
    }
} @available_modules;

# Firmware files
my @firmware_files = qw(bin/0x00000.bin bin/0x10000.bin);
my @firmware_sizes = map {
    -s $_ || 0;
} @firmware_files;


# Heredoc for header
my $header = <<EOF;

    **********************************************
    *                                            *
    *  Docker image: fauria/nodemcu              *
    *  https://github.com/fauria/docker-nodemcu  *
    *                                            *
    **********************************************

    FIRMWARE MODULES
    ----------------
EOF

# Heredoc for footer
my $footer = <<EOF;

    OUTPUT FILES
    ------------
    · %s: %.2f KB
    · %s: %.2f KB

    HOW TO FLASH
    ------------
    * Flash device using:
    esptool.py --port /path/to/serial_port write_flash 0x00000 /host/volume/0x00000.bin 0x10000 /host/volume/0x10000.bin

    * Example:
    esptool.py --port /dev/cu.SLAB_USBtoUART write_flash 0x00000 0x00000.bin 0x10000 0x10000.bin

    DOCUMENTATION
    -------------
    * NodeMCU: https://nodemcu.readthedocs.io/en/master
    * Firmware: https://github.com/nodemcu/nodemcu-firmware
    * esptool: https://github.com/espressif/esptool

EOF

# Display header and list of modules
print $header;
foreach my $module (sort keys %enabled_modules) {
    printf "    · $module: %s\n", $enabled_modules{$module} ? GREEN.'Yes'.RESET : RED.'No'.RESET
}

# Set custom defined modules. Iterate over original file
# instead of creating a new one to avoid boilerplate code.
if (scalar(@custom_modules)) {
    open CUSTOM_CONFIG, '>'.$user_config.'.custom';
    seek DEFAULT_CONFIG, 0, 0;
    while (<DEFAULT_CONFIG>) {
        # Disable all directives by default:
        my $directive = '//'.$_;
        foreach my $module (sort keys %enabled_modules) {
            my $module_name = qr/LUA_USE_MODULES_$module/;
            # If module in use, remove comment and leading spaces:
            if ($enabled_modules{$module} and /^.*${module_name}$/) {
                $_ =~ s/^\/\/\s?//;
                $directive = $_;
            }
        }
        # Save to custom config file
        print CUSTOM_CONFIG $directive;
    }
    # rename $user_config.'.custom', $user_config;
}

# Build firmware
print("\n    BUILDING FIRMWARE... ");
`/usr/bin/make`;
print(" DONE.\n");

# Display footer and notes
printf $footer, $firmware_files[0], $firmware_sizes[0]/1024.0, $firmware_files[1], $firmware_sizes[1]/1024.0;
