// Tamagotchi Paradise UART adapter
// Hook (Basic_rev2.stl) + CP210X pocket + snap-fit lid.

$fn = 64;
eps = 0.05;

tolerance = 0.2;
show_board_preview = true;
show_pin_preview = true;

// 0 = adapter, 1 = lid, 2 = assembled
// Use a number so `openscad -D part=0` works on Windows (no quoted strings).
part = 0;

// --- CP210X board ---
pcb_l = 24.2;
pcb_w = 15.7;
pcb_h = 4.8;
pcb_thickness = 1.6;
usb_w = 9.0;
usb_h = 3.2;
usb_overhang = 1.2;
usb_shell_l = 7.2;
usb_shell_w = 9.0;
usb_shell_h = 3.2;
pad_pitch_y = 2.54;
board_preview_angle = 0;
pcb_insert_x_offset = 0;
pcb_insert_y_offset = 0;

// --- Hook ---
stl_file = "reference-stl/Basic_rev2.stl";
hook_l = 35.0;
hook_w = 14.0;
hook_h = 6.35;
hook_r = 2.0;

// A-SMT pogo (pin.png), installed plunger-down, flange on pocket floor
pin_xs = [-12, 0, 12];
pin_flange_d = 3.0;
pin_flange_h = 0.5;
pin_barrel_d = 2.0;
pin_barrel_h = 7.0;
pin_tip_d = 1.5;
pin_tip_h = 2.5;
pin_hole_clear = 0.15;
pin_sleeve_od = 3.7;
pin_sleeve_z = 3.2;

// --- Pocket / lid ---
wall = 1.6;
headroom = 0.6;
shell_extra = 2;

usb_cut_tol = 0.6;
usb_cut_round_r = 2.5;
usb_cut_z_offset = 2;

lid_t = 1.6;
lid_clear = 0.28;
lid_skirt_h = 2.2;
lid_rim_t = 1.15;
lid_snap_d = 0.7;
lid_snap_h = 1.4;
lid_snap_w = 12.0;
lid_pry_w = 10.0;
lid_pry_d = 1.2;

// --- Derived ---
pcb_cav_l = pcb_l + 2 * tolerance + usb_overhang;
pcb_cav_w = pcb_w + 2 * tolerance;
pcb_cav_h = pcb_h + tolerance + headroom;
shell_h = wall + pcb_cav_h + shell_extra;

usb_cut_w = usb_w + 2 * tolerance + 0.6;
usb_cut_h = usb_h + 2 * tolerance;

hook_x0 = -hook_l / 2;
hook_y0 = -hook_w / 2;
shell_x0 = hook_x0;
shell_x1 = hook_l / 2;
shell_y0 = -pcb_cav_w / 2 - wall;
shell_y1 = pcb_cav_w / 2 + wall;
shell_l = shell_x1 - shell_x0;
shell_w = shell_y1 - shell_y0;
shell_ox = shell_x0 + pcb_insert_x_offset;
shell_oy = shell_y0 + pcb_insert_y_offset;

pin_barrel_hole = pin_barrel_d + 2 * pin_hole_clear;
pin_flange_hole = pin_flange_d + 2 * pin_hole_clear;
pin_floor_z = hook_h + wall;
pin_seat_z = pin_floor_z - pin_flange_h;

if (part == 1) {
    lid();
} else {
    adapter();
    if (part == 2)
        color([0.25, 0.55, 0.85, 0.72])
            lid();
}

module adapter() {
    difference() {
        union() {
            hook();
            pcb_shell();
            pin_sleeves();
        }
        pcb_cavity();
        usb_cutout();
        pin_through_holes();
        lid_snap_recesses();
    }
    if (show_board_preview)
        board_preview();
    if (show_pin_preview)
        pin_preview();
}

module hook() {
    import(stl_file, convexity = 16);
}

module pcb_shell() {
    translate([shell_ox, shell_oy, hook_h])
        rounded_cube([shell_l, shell_w, shell_h], hook_r);

    translate([hook_x0, hook_y0, hook_h - 0.5])
        rounded_cube([hook_l, hook_w, 0.5 + eps], hook_r);
}

module pcb_cavity() {
    translate([shell_ox + wall, shell_oy + wall, hook_h + wall])
        rounded_cube([
            shell_l - 2 * wall,
            shell_w - 2 * wall,
            shell_h - wall + 1
        ], 0.6);
}

module usb_cutout() {
    cut_w = usb_cut_w + 2 * usb_cut_tol;
    cut_h = usb_cut_h + 2 * usb_cut_tol;
    depth = wall + 6;
    r = min(usb_cut_round_r, cut_w / 2 - 0.2, cut_h / 2 - 0.2);
    x0 = shell_ox - 0.2;
    y0 = shell_oy + (shell_w - cut_w) / 2;
    z0 = hook_h + wall + pcb_thickness + usb_cut_z_offset;

    translate([x0, y0 + cut_w / 2, z0])
        rotate([0, 90, 0])
            linear_extrude(height = depth)
                offset(r = r)
                    square([cut_h - 2 * r, cut_w - 2 * r], center = true);
}

module pin_sleeves() {
    h = pin_floor_z - pin_sleeve_z + 0.2;
    for (x = pin_xs)
        translate([x, 0, pin_sleeve_z])
            cylinder(h = h, d = pin_sleeve_od);
}

module pin_through_holes() {
    for (x = pin_xs) {
        translate([x, 0, -1])
            cylinder(h = pin_floor_z + 2, d = pin_barrel_hole);
        translate([x, 0, pin_seat_z])
            cylinder(h = pin_flange_h + 1, d = pin_flange_hole);
        translate([x, 0, -0.2])
            cylinder(h = 1.2, d1 = pin_barrel_hole + 0.8, d2 = pin_barrel_hole);
    }
}

module pin_preview() {
    for (x = pin_xs)
        translate([x, 0, pin_seat_z])
            pogo_pin();
}

module pogo_pin() {
    color([0.90, 0.75, 0.20, 0.95]) {
        cylinder(h = pin_flange_h, d = pin_flange_d);
        translate([0, 0, -pin_barrel_h])
            cylinder(h = pin_barrel_h, d = pin_barrel_d);
        translate([0, 0, -pin_barrel_h - pin_tip_h + pin_tip_d / 2]) {
            cylinder(h = pin_tip_h - pin_tip_d / 2, d = pin_tip_d);
            sphere(d = pin_tip_d);
        }
    }
}

module board_preview() {
    board_x_offset = 3.5;
    board_x0 = -pcb_l / 2 - board_x_offset;
    board_y0 = -pcb_w / 2;
    header_x = pcb_l / 2 - 1.2 - board_x_offset;

    translate([pcb_insert_x_offset, pcb_insert_y_offset, hook_h + wall])
        rotate([0, 0, board_preview_angle])
            union() {
                color([0.35, 0.05, 0.45, 0.70])
                    translate([board_x0, board_y0, 0])
                        cube([pcb_l, pcb_w, pcb_thickness]);

                translate([board_x0 - usb_overhang, 0, pcb_thickness])
                    usb_c_receptacle();

                for (p = [1 : 6]) {
                    py = (p - 3.5) * pad_pitch_y;
                    pin_col =
                        p == 3 ? [0.90, 0.25, 0.25, 0.95] :
                        p == 4 ? [1.00, 0.65, 0.15, 0.95] :
                        p == 5 ? [0.25, 0.85, 0.40, 0.95] :
                                 [0.15, 0.15, 0.15, 0.65];

                    translate([header_x, py, pcb_thickness + 0.2]) {
                        color(pin_col)
                            cylinder(h = 0.8, d = 0.9);
                    }
                }
            }
}

module usb_c_receptacle() {
    w = usb_shell_w;
    h = usb_shell_h;
    l = usb_shell_l;
    metal_t = 0.32;
    cavity_l = 5.5;
    inner_w = w - 2 * metal_t;
    inner_h = h - 2 * metal_t;
    tongue_w = 6.55;
    tongue_h = 0.72;
    tongue_l = 4.3;
    tab_l = 2.4;
    tab_w = 0.85;
    tab_h = 0.28;

    color([0.76, 0.78, 0.81, 0.96])
        difference() {
            usb_c_capsule(l, w, h);
            translate([-eps, 0, metal_t])
                usb_c_capsule(cavity_l + eps, inner_w, inner_h);
        }

    color([0.10, 0.10, 0.11, 0.96]) {
        translate([cavity_l - 0.35, 0, metal_t + 0.08])
            usb_c_capsule(l - cavity_l + 0.35, inner_w - 0.2, inner_h - 0.16);
        translate([0.28, 0, (h - tongue_h) / 2])
            usb_c_capsule(tongue_l, tongue_w, tongue_h);
    }

    color([0.90, 0.70, 0.18, 0.96]) {
        n = 8;
        pad_w = 0.32;
        pad_l = 2.3;
        span = 5.5;
        z0 = (h - tongue_h) / 2;
        for (side = [0, 1])
            for (i = [0 : n - 1]) {
                py = -span / 2 + i * span / (n - 1);
                translate([0.85, py, z0 + (side ? tongue_h : 0) - 0.03])
                    cube([pad_l, pad_w, 0.06], center = true);
            }
    }

    color([0.76, 0.78, 0.81, 0.96])
        for (s = [-1, 1])
            translate([l * 0.42, s * (w / 2 + tab_w / 2), tab_h / 2])
                cube([tab_l, tab_w, tab_h], center = true);
}

module usb_c_capsule(l, w, h) {
    r = h / 2;
    hull()
        for (s = [-1, 1])
            translate([0, s * (w / 2 - r), r])
                rotate([0, 90, 0])
                    cylinder(h = l, r = r);
}

module lid() {
    if (part == 1)
        lid_for_print();
    else
        translate([shell_ox, shell_oy, hook_h + shell_h])
            lid_body();
}

module lid_for_print() {
    translate([0, shell_w, lid_t])
        rotate([180, 0, 0])
            lid_body();
}

module lid_body() {
    inner_l = shell_l - 2 * wall;
    inner_w = shell_w - 2 * wall;
    skirt_l = inner_l - 2 * lid_clear;
    skirt_w = inner_w - 2 * lid_clear;
    skirt_r = 0.6;
    cut_l = skirt_l - 2 * lid_rim_t;
    cut_w = skirt_w - 2 * lid_rim_t;
    cut_r = max(0.2, skirt_r - lid_rim_t);

    difference() {
        union() {
            rounded_cube([shell_l, shell_w, lid_t], hook_r);
            translate([wall + lid_clear, wall + lid_clear, -lid_skirt_h])
                rounded_cube([skirt_l, skirt_w, lid_skirt_h + eps], skirt_r);
            lid_snap_beads(skirt_l, skirt_w);
        }
        translate([
            wall + lid_clear + lid_rim_t,
            wall + lid_clear + lid_rim_t,
            -lid_skirt_h - 1
        ])
            rounded_cube([cut_l, cut_w, lid_skirt_h + 1 + eps], cut_r);
        lid_pry_notch();
    }
}

module lid_snap_beads(skirt_l, skirt_w) {
    x0 = wall + lid_clear + (skirt_l - lid_snap_w) / 2;
    z0 = -lid_skirt_h;
    translate([x0, wall + lid_clear + skirt_w, z0])
        snap_prism(lid_snap_w, 1, lid_snap_h, lid_snap_d);
    translate([x0, wall + lid_clear, z0])
        snap_prism(lid_snap_w, -1, lid_snap_h, lid_snap_d);
}

module lid_snap_recesses() {
    z0 = hook_h + shell_h - lid_skirt_h;
    gw = lid_snap_w + 1.6;
    gh = lid_snap_h + 0.35;
    gd = lid_snap_d - lid_clear + 0.22;
    gx = shell_ox + wall + lid_clear + (shell_l - 2 * wall - 2 * lid_clear - gw) / 2;

    translate([gx, shell_oy + shell_w - wall, z0])
        snap_prism(gw, 1, gh, gd);
    translate([gx, shell_oy + wall, z0])
        snap_prism(gw, -1, gh, gd);
}

module snap_prism(len, y_dir, h, d) {
    hull() {
        translate([0, y_dir > 0 ? 0 : -0.02, 0])
            cube([len, 0.02, h]);
        translate([0, y_dir * d, h / 2])
            cube([len, 0.02, 0.02]);
    }
}

module lid_pry_notch() {
    translate([shell_l / 2, shell_w + 0.2, lid_t])
        rotate([0, 90, 0])
            cylinder(h = lid_pry_w, d = lid_pry_d * 2, center = true);
}

module rounded_cube(size, r) {
    x = size[0];
    y = size[1];
    z = size[2];
    rr = min(r, x / 2 - 0.05, y / 2 - 0.05);
    linear_extrude(height = z)
        translate([rr, rr])
            offset(r = rr)
                square([x - 2 * rr, y - 2 * rr]);
}
