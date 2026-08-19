// Tamagotchi Paradise UART adapter — all-in-one
// Hook + low-profile CP210X pocket + separate snap-fit lid.

$fn = 64;
eps = 0.05;

tolerance = 0.2;
show_board_preview = true;
show_board_labels = false;

// What to render/export
// "adapter"   -> hook + open-top pocket
// "lid"       -> snap lid, print orientation (top on bed)
// "assembled" -> both together (for visual check)
layout = "assembled";

// --- CP210X board ---
pcb_l = 24.2;
pcb_w = 15.7;
pcb_h = 4.8;
pcb_thickness = 1.6;
usb_w = 9.0;
usb_h = 3.2;
usb_overhang = 1.2;
usb_shell_l = 7.2; // connector depth into the PCB area
usb_shell_w = 9.0; // visible width across the short board edge
usb_shell_h = 3.2;

pad_col_x = 2.54;
pad_pitch_y = 2.54;
pad_size = 1.4;

// --- Hook (Basic_rev2.stl) ---
hook_l = 35.0;
hook_w = 14.0;
hook_h = 6.35;
hook_r = 2.0;

pin_xs = [-12, 0, 12];
pin_body_d = 3.0;       // pogo barrel OD (Basic_rev2.stl)
pin_tip_d = 2.0;        // pogo tip OD
pin_length = 7.5;       // pogo pin total length
pin_shoulder_z = 3.5;   // tip / barrel step height from hook floor

left_x0 = -9.0;
left_x1 = -3.0;
left_gap = 10.0;
left_roof = 3.0;
left_lip = 3.0;
left_post_w = 1.5;
left_post_y = 5.2;
left_post_z = -3.5;

right_x0 = 3.0;
right_x1 = 9.0;
right_w = 9.6;
right_gap = 5.6;
right_roof = -0.6;
right_lip = 3.0;
right_cut_x0 = 2.0;
right_cut_x1 = 10.0;

wall = 1.6;
headroom = 0.6;
retain_lip = 0.5;

hook_source = "stl";
stl_file = "Basic_rev2.stl";
// In the CP210X picture you provided, the USB-C pads are on the left side (17-20),
// while the header pins (1-6) are on the right side.
// This switch moves the USB-C opening to the correct case face.
usb_open_side = "back"; // "front" | "back"
board_preview_angle = 0; // rotate CP210X preview only (0/90/180/270)
// Tune how the CP210X pocket is positioned relative to the fixed pogo holes.
pcb_insert_x_offset = 0; // mm
pcb_insert_y_offset = 0; // mm

// --- Snap lid (separate part) ---
lid_t = 1.6;           // lid plate thickness
lid_clear = 0.28;      // skirt to inner-wall gap
lid_skirt_h = 2.2;     // how far the skirt drops into the pocket
lid_rim_t = 1.15;      // skirt wall thickness (flexes for the snap)
lid_snap_d = 0.7;      // triangular bead depth (45° faces)
lid_snap_h = 1.4;      // triangular bead height
lid_snap_w = 12.0;     // bead length along the long walls
lid_pry_w = 10.0;
lid_pry_d = 1.2;

// Derived
pcb_cav_l = pcb_l + 2 * tolerance + usb_overhang;
pcb_cav_w = pcb_w + 2 * tolerance;
pcb_cav_h = pcb_h + tolerance + headroom;
shell_h = wall + pcb_cav_h + 2;

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
shell_top_x0 = -pcb_cav_l / 2 - wall;
shell_top_x1 = pcb_cav_l / 2 - wall;

pcb_x0 = -pcb_cav_l / 2;
pcb_x1 = pcb_cav_l / 2;
pcb_y0 = -pcb_cav_w / 2;
pcb_y1 = pcb_cav_w / 2;

pin_body_hole = pin_body_d + 2 * tolerance;
pin_tip_hole = pin_tip_d + 2 * tolerance;
pin_bore_top_z = hook_h + wall + 1.5;

if (layout == "adapter") {
    adapter();
} else if (layout == "lid") {
    lid();
} else if (layout == "assembled") {
    adapter();
    color([0.25, 0.55, 0.85, 0.72])
        lid();
} else {
    adapter();
}

module adapter() {
    difference() {
        union() {
            hook();
            pcb_shell();
        }
        pcb_cavity();
        usb_cutout();
        pin_through_holes();
        lid_snap_recesses();
    }
    if (show_board_preview)
        board_preview();
}

module pcb_shell() {
    translate([shell_x0 + pcb_insert_x_offset, shell_y0 + pcb_insert_y_offset, hook_h])
        rounded_cube([shell_x1 - shell_x0, shell_y1 - shell_y0, shell_h], hook_r);

    translate([hook_x0, hook_y0, hook_h - 0.5])
        rounded_cube([hook_l, hook_w, 0.5 + eps], hook_r);
}

module pcb_cavity() {
    translate([shell_x0 + wall + pcb_insert_x_offset, shell_y0 + wall + pcb_insert_y_offset, hook_h + wall])
        rounded_cube([
            shell_x1 - shell_x0 - 2 * wall,
            shell_y1 - shell_y0 - 2 * wall,
            shell_h - wall + 1
        ], 0.6);
}

// Rounded USB-C cutout with clearance (not an exact model).
// The opening is oversized slightly and corner-rounded so it fits snugly without being tight.
usb_cut_tol = 0.8;      // extra clearance around the USB-C shape (mm)
usb_cut_round_r = 2.5; // rounding radius for the cutout corners (mm)

module usb_cutout() {
    usb_z_offset = 2;
    usb_z = hook_h + wall + pcb_thickness + usb_z_offset;
    
    // Dimensions in the face plane
    cut_w = usb_cut_w + 2 * usb_cut_tol; // Now along the Y direction (shorter width face)
    cut_h = usb_cut_h + 2 * usb_cut_tol; // Z direction
    depth = wall + 6;                    // Cut depth through the wall
    
    r = min(usb_cut_round_r, cut_w / 2 - 0.2, cut_h / 2 - 0.2);
    
    // Position logic shifted to short wall
    x0 = (shell_x0 - 0.2); // Align with the outer edge of the X-axis wall
    y0 = shell_y0 + (shell_y1 - shell_y0 - cut_w) / 2; // Center along the Y-axis
    z0 = usb_z;
    
    // Extrude through the X wall (Inward along X axis)
    translate([x0, y0 + cut_w / 2, z0])
    rotate([0, 90, 0]) // Rotated to pierce through the X-face
    linear_extrude(height = depth)
    offset(r = r)
    square([cut_h - 2 * r, cut_w - 2 * r], center = true);
}

// Stepped through-bores for pogo pins (top insert → bottom contacts Paradise prongs).
module pin_through_holes() {
    bore_bottom_z = -left_lip - 1;
    tip_h = pin_shoulder_z + left_lip + 1.2;
    for (x = pin_xs)
        translate([x, 0, bore_bottom_z]) {
            cylinder(h = tip_h, d = pin_tip_hole);
            translate([0, 0, tip_h - eps])
                cylinder(h = pin_bore_top_z - bore_bottom_z - tip_h + 2 * eps, d = pin_body_hole);
            translate([0, 0, -0.8])
                cylinder(h = 1.0, d1 = pin_body_hole + 0.6, d2 = pin_tip_hole);
        }
}
module board_preview() {
    board_z = hook_h + wall;
    // control the x, y poistion of preview cp210x board
    board_x_offset = 3.5;
    board_x0 = (-pcb_l / 2) - board_x_offset;
    board_y0 = -pcb_w / 2;
    angle = board_preview_angle;

    translate([pcb_insert_x_offset, pcb_insert_y_offset, board_z])
        rotate([0, 0, angle])
            union() {
                // PCB body
                color([0.35, 0.05, 0.45, 0.70])
                    translate([board_x0, board_y0, 0])
                        cube([pcb_l, pcb_w, pcb_thickness]);

                // USB-C receptacle (preview)
                translate([board_x0 - usb_overhang, 0, pcb_thickness])
                    usb_c_receptacle();

                // Right header pins 1..6 (single column)
                // Per your board description:
                // pin3 = RXI, pin4 = TXO, pin5 = GND
                header_x = (-pcb_l / 2) * -1 - 1.2 - board_x_offset;
                for (p = [1 : 6]) {
                    pin_i = p - 3.5; // centers pin3/4 around y=0-ish
                    py = pin_i * pad_pitch_y;

                    is_rx = (p == 3);
                    is_tx = (p == 4);
                    is_gnd = (p == 5);

                    pin_col =
                        is_rx ? [0.90, 0.25, 0.25, 0.95] :
                        is_tx ? [1.00, 0.65, 0.15, 0.95] :
                        is_gnd ? [0.25, 0.85, 0.40, 0.95] :
                                 [0.15, 0.15, 0.15, 0.65];

                    translate([header_x, py, pcb_thickness + 0.2]) {
                        color(pin_col)
                            cylinder(h = 0.8, d = 0.9);

                        if (show_board_labels)
                            color([0, 0, 0, 0.9])
                                translate([0, 0, 1.05])
                                    text(str(p), size = 2.0, halign = "center", valign = "center");
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

module hook() {
    if (hook_source == "stl") {
        import(stl_file, convexity = 16);
    } else {
        hook_native();
    }
}

module hook_native() {
    union() {
        difference() {
            union() {
                translate([hook_x0, hook_y0, 0])
                    rounded_cube([hook_l, hook_w, hook_h], hook_r);

                translate([left_x0, hook_y0, -left_lip])
                    cube([left_x1 - left_x0, hook_w, left_lip + left_roof + eps]);

                translate([right_x0, -right_w / 2, -right_lip])
                    cube([right_x1 - right_x0, right_w, right_lip + hook_h + eps]);
            }

            translate([left_x0 - eps, -left_gap / 2, -left_lip - eps])
                cube([left_x1 - left_x0 + 2 * eps, left_gap, left_lip + left_roof + 2 * eps]);

            translate([right_x0 - eps, -right_gap / 2, -right_lip - eps])
                cube([right_x1 - right_x0 + 2 * eps, right_gap, right_lip + right_roof + 2 * eps]);

            for (s = [-1, 1])
                translate([
                    right_cut_x0,
                    s > 0 ? right_w / 2 : hook_y0 - 1,
                    -eps
                ])
                    cube([
                        right_cut_x1 - right_cut_x0,
                        (hook_w - right_w) / 2 + 1,
                        hook_h + 2 * eps
                    ]);

            pin_holes_hook();
        }

        translate([left_x0, -left_post_y / 2, left_post_z])
            cube([left_post_w, left_post_y, left_roof - left_post_z]);
        translate([left_x1 - left_post_w, -left_post_y / 2, left_post_z])
            cube([left_post_w, left_post_y, left_roof - left_post_z]);
    }
}

module pin_holes_hook() {
    for (x = pin_xs)
        translate([x, 0, -left_lip - 1]) {
            cylinder(h = pin_shoulder_z + left_lip + 1.2, d = pin_tip_hole);
            translate([0, 0, pin_shoulder_z + left_lip + 1 - eps])
                cylinder(h = pin_bore_top_z + left_lip + 1, d = pin_body_hole);
            cylinder(h = 1.0, d1 = pin_body_hole + 0.6, d2 = pin_tip_hole);
        }
}

module lid() {
    if (layout == "lid")
        lid_for_print();
    else
        translate([
            shell_x0 + pcb_insert_x_offset,
            shell_y0 + pcb_insert_y_offset,
            hook_h + shell_h
        ])
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
    y_pos = wall + lid_clear + skirt_w;
    y_neg = wall + lid_clear;
    z0 = -lid_skirt_h;
    translate([x0, y_pos, z0])
        snap_prism(lid_snap_w, 1, lid_snap_h, lid_snap_d);
    translate([x0, y_neg, z0])
        snap_prism(lid_snap_w, -1, lid_snap_h, lid_snap_d);
}

module lid_snap_recesses() {
    ox = shell_x0 + pcb_insert_x_offset;
    oy = shell_y0 + pcb_insert_y_offset;
    z0 = hook_h + shell_h - lid_skirt_h;
    gw = lid_snap_w + 1.6;
    gh = lid_snap_h + 0.35;
    gd = lid_snap_d - lid_clear + 0.22;
    gx = ox + wall + lid_clear + (shell_l - 2 * wall - 2 * lid_clear - gw) / 2;

    translate([gx, oy + shell_w - wall, z0])
        snap_prism(gw, 1, gh, gd);
    translate([gx, oy + wall, z0])
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
