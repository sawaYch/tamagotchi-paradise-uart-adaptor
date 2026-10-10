// Tamagotchi Paradise UART adapter
// Hook (Basic_rev2.stl) + FT232RL pocket + magnetic lid.

$fn = 64;
eps = 0.05;

tolerance = 0.2;
show_board_preview = true;
show_pin_preview = true;
show_magnet_preview = false;

// 0 = adapter, 1 = lid, 2 = assembled
// Use a number so `openscad -D part=0` works on Windows (no quoted strings).
part = 2;

// --- FT232RL USB-C module (36 x 18 mm) ---
pcb_l = 36.0;
pcb_w = 18.0;
pcb_thickness = 1.6;
jumper_h = 9.0;
pcb_h = pcb_thickness + jumper_h;
usb_w = 9.0;
usb_h = 3.2;
usb_overhang = 1.2;
usb_shell_l = 7.2;
usb_shell_w = 9.0;
usb_shell_h = 3.2;
header_overhang = 2.0;
pad_pitch_y = 2.54;
board_preview_angle = 0;
pcb_insert_x_offset = 0;
pcb_insert_y_offset = 0;

// --- Hook ---
stl_file = "../../reference-stl/Basic_rev2.stl";
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
wall_inner = wall - 0.1;
// JLC3DP: walls > 1.2 mm, and nothing thinner than 0.8 mm.
min_wall = 1.4;
headroom = 0.6;
shell_extra = 2;

// Space under the PCB: solder fillet + 24 AWG + user-added isolator sheet
solder_h = 1.0;
wire_od = 1.4;
isolator_h = 1.0;
solder_well_h = solder_h + wire_od;
board_lift = solder_well_h + isolator_h;
ledge_w = 1.8;
ledge_h = min_wall;

usb_cut_tol = 0.6;
usb_cut_round_r = 2.5;

// 5 x 2 mm N52 discs, one pair at each corner. 2 mm is thick enough to
// hold this lid (~0.6 kg pull per magnet) without a deep pocket.
mag_d = 5.0;
mag_h = 2.0;
mag_fit = 0.3;
mag_pocket_d = mag_d + mag_fit;
mag_pocket_h = mag_h + 0.15;
mag_floor = min_wall;
mag_wall_skin = min_wall;
mag_inset = mag_pocket_d / 2 + mag_wall_skin;
mag_boss_d = mag_pocket_d + 2 * min_wall;
mag_boss_h = mag_pocket_h + mag_floor;
lid_h = mag_pocket_h + mag_floor;
lid_pry_w = 10.0;
lid_pry_d = 1.2;

// --- Hook reinforcement (imported Basic_rev2.stl) ---
prong_root_y = -2.5;
prong_root_w = 5.0;
prong_root_depth = 3.45;
prong_root_extra = 1.25;
prong_root_overlap = 0.25;

// Detent faces that clip the Tamagotchi's grab bar (measured from STL)
prong_grab_shave = 0;
prong_grab_face_l = -7.112;
prong_grab_face_r = -4.888;
prong_grab_z = -2.49;

grab_cyl_x = 6.0;
grab_cyl_z = -0.20;
grab_cyl_d = 2.7; // original = ~2.4mm
grab_cyl_len = 5.7;

// --- Derived ---
pcb_cav_l = pcb_l + 2 * tolerance + usb_overhang + header_overhang;
pcb_cav_w = pcb_w + 2 * tolerance;
pcb_cav_h = pcb_h + tolerance + headroom;
shell_h = wall + board_lift + pcb_cav_h + shell_extra;

usb_cut_w = usb_w + 2 * tolerance + 0.6;
usb_cut_h = usb_h + 2 * tolerance;

hook_x0 = -hook_l / 2;
hook_y0 = -hook_w / 2;
shell_x0 = hook_x0;
shell_l = pcb_cav_l + 2 * wall;
shell_x1 = shell_x0 + shell_l;
shell_y0 = -pcb_cav_w / 2 - wall;
shell_y1 = pcb_cav_w / 2 + wall;
shell_w = shell_y1 - shell_y0;
shell_ox = shell_x0 + pcb_insert_x_offset;
shell_oy = shell_y0 + pcb_insert_y_offset;

pin_barrel_hole = pin_barrel_d + 2 * pin_hole_clear;
pin_flange_hole = pin_flange_d + 2 * pin_hole_clear;
pin_floor_z = hook_h + wall;
pin_seat_z = pin_floor_z - pin_flange_h;
pcb_z = pin_floor_z + board_lift;
ledge_z = pin_floor_z + solder_well_h - ledge_h;

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
      difference() {
        union() {
          hook();
          pcb_shell();
          pin_sleeves();
          prong_root_reinforcement();
          hook_rib_fill();
          grab_cylinder();
        }
        pcb_cavity();
        usb_cutout();
        pin_through_holes();
        prong_grab_relief();
      }
      isolator_ledges();
      magnet_bosses_case();
    }
    magnet_pockets_case();
  }
  if (show_board_preview)
    board_preview();
  if (show_pin_preview)
    pin_preview();
  if (show_magnet_preview)
    magnet_preview_case();
}

module hook() {
  import(stl_file, convexity=16);
}

module pcb_shell() {
  translate([shell_ox, shell_oy, hook_h])
    rounded_cube([shell_l, shell_w, shell_h], hook_r);

  translate([hook_x0, hook_y0, hook_h - 0.5])
    rounded_cube([hook_l, hook_w, 0.5 + eps], hook_r);
}

module pcb_cavity() {
  translate([shell_ox + wall_inner, shell_oy + wall_inner, hook_h + wall])
    rounded_cube(
      [
        shell_l - 2 * wall_inner,
        shell_w - 2 * wall_inner,
        shell_h - wall + 1,
      ], 0.6
    );
}

module usb_cutout() {
  cut_w = usb_cut_w + 2 * usb_cut_tol;
  cut_h = usb_cut_h + 2 * usb_cut_tol;
  depth = wall + 6;
  r = min(usb_cut_round_r, cut_w / 2 - 0.2, cut_h / 2 - 0.2);
  x0 = shell_ox - 0.2;
  y0 = shell_oy + (shell_w - cut_w) / 2;
  z0 = pcb_z + pcb_thickness + usb_h / 2;

  translate([x0, y0 + cut_w / 2, z0])
    rotate([0, 90, 0])
      linear_extrude(height=depth)
        offset(r=r)
          square([cut_h - 2 * r, cut_w - 2 * r], center=true);
}

module pin_sleeves() {
  h = pin_floor_z - pin_sleeve_z + 0.2;
  for (x = pin_xs)
    translate([x, 0, pin_sleeve_z])
      cylinder(h=h, d=pin_sleeve_od);
}

module pin_through_holes() {
  for (x = pin_xs) {
    translate([x, 0, -1])
      cylinder(h=pin_floor_z + 2, d=pin_barrel_hole);
    translate([x, 0, pin_seat_z])
      cylinder(h=pin_flange_h + 1, d=pin_flange_hole);
    translate([x, 0, -0.2])
      cylinder(h=1.2, d1=pin_barrel_hole + 0.8, d2=pin_barrel_hole);
  }
}

module pin_preview() {
  for (x = pin_xs)
    translate([x, 0, pin_seat_z])
      pogo_pin();
}

module pogo_pin() {
  color([0.90, 0.75, 0.20, 0.95]) {
    cylinder(h=pin_flange_h, d=pin_flange_d);
    translate([0, 0, -pin_barrel_h])
      cylinder(h=pin_barrel_h, d=pin_barrel_d);
    translate([0, 0, -pin_barrel_h - pin_tip_h + pin_tip_d / 2]) {
      cylinder(h=pin_tip_h - pin_tip_d / 2, d=pin_tip_d);
      sphere(d=pin_tip_d);
    }
  }
}

module board_preview() {
  board_x0 = hook_x0 + wall;
  board_y0 = -pcb_w / 2;
  ic_l = 10.3;
  ic_w = 5.3;
  ic_h = 1.65;
  jumper_x = board_x0 + 26.2;
  jumper_post_h = 2.5;
  header_x = board_x0 + pcb_l - 2.5;
  header_body_w = 6 * pad_pitch_y + 0.5;

  translate([pcb_insert_x_offset, pcb_insert_y_offset, pcb_z])
    rotate([0, 0, board_preview_angle])
      union() {
        color([0.78, 0.12, 0.14, 0.82])
          translate([board_x0, board_y0, 0])
            cube([pcb_l, pcb_w, pcb_thickness]);

        translate([board_x0 - usb_overhang, 0, pcb_thickness])
          usb_c_receptacle();

        color([0.10, 0.10, 0.10, 0.96])
          translate(
            [
              board_x0 + 14.2,
              -ic_w / 2,
              pcb_thickness,
            ]
          )
            cube([ic_l, ic_w, ic_h]);

        color([0.12, 0.12, 0.12, 0.96])
          translate(
            [
              jumper_x - 1.25,
              -pad_pitch_y * 1.5 - 1.2,
              pcb_thickness,
            ]
          )
            cube([2.5, pad_pitch_y * 3 + 2.4, jumper_post_h]);

        color([0.08, 0.08, 0.08, 0.96])
          translate([jumper_x - 2.2, 0.2, pcb_thickness + jumper_post_h])
            cube([4.4, pad_pitch_y + 0.4, jumper_h - jumper_post_h]);

        color([0.12, 0.12, 0.12, 0.96])
          translate(
            [
              header_x,
              -header_body_w / 2,
              pcb_thickness,
            ]
          )
            cube([2.5, header_body_w, 2.5]);

        for (p = [1:6]) {
          py = (3.5 - p) * pad_pitch_y;
          pin_col =
            p == 2 ? [0.35, 0.72, 0.95, 0.95]
            : p == 3 ? [0.25, 0.85, 0.40, 0.95]
            : p == 6 ? [0.55, 0.32, 0.16, 0.95]
            : [0.82, 0.68, 0.18, 0.92];

          translate([header_x + 1.25, py, pcb_thickness + 2.5])
            color(pin_col)
              cylinder(h=4.2, d=0.64);
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
      for (i = [0:n - 1]) {
        py = -span / 2 + i * span / (n - 1);
        translate([0.85, py, z0 + (side ? tongue_h : 0) - 0.03])
          cube([pad_l, pad_w, 0.06], center=true);
      }
  }

  color([0.76, 0.78, 0.81, 0.96])for (s = [-1, 1])
    translate([l * 0.42, s * (w / 2 + tab_w / 2), tab_h / 2])
      cube([tab_l, tab_w, tab_h], center=true);
}

module usb_c_capsule(l, w, h) {
  r = h / 2;
  hull()for (s = [-1, 1])
    translate([0, s * (w / 2 - r), r])
      rotate([0, 90, 0])
        cylinder(h=l, r=r);
}

module prong_root_reinforcement() {
  gusset_tip_w = min_wall;
  gusset_root_h = min_wall;
  gusset_tip_h = min_wall;

  hull() {
    translate(
      [
        -9.0 - prong_root_extra,
        prong_root_y,
        -0.15,
      ]
    )
      cube(
        [
          prong_root_extra + prong_root_overlap,
          prong_root_w,
          gusset_root_h,
        ]
      );
    translate(
      [
        -9.0 - prong_root_overlap,
        prong_root_y,
        -prong_root_depth,
      ]
    )
      cube([gusset_tip_w, prong_root_w, gusset_tip_h]);
  }

  hull() {
    translate(
      [
        -3.0 - prong_root_overlap,
        prong_root_y,
        -0.15,
      ]
    )
      cube(
        [
          prong_root_extra + prong_root_overlap,
          prong_root_w,
          gusset_root_h,
        ]
      );
    translate(
      [
        -3.0 - gusset_tip_w + prong_root_overlap,
        prong_root_y,
        -prong_root_depth,
      ]
    )
      cube([gusset_tip_w, prong_root_w, gusset_tip_h]);
  }
}

// Basic_rev2 ribs are 1.79 mm above z=0.3 and only 1.0 mm below that step.
module hook_rib_fill() {
  y0 = -1.85;
  yw = 3.7;
  zh = 0.55;
  translate([0.90, y0, 0])
    cube([0.90, yw, zh]);
  translate([10.20, y0, 0])
    cube([0.90, yw, zh]);
}

module grab_cylinder() {
  translate([grab_cyl_x, -grab_cyl_len / 2, grab_cyl_z])
    rotate([-90, 0, 0])
      cylinder(h=grab_cyl_len, d=grab_cyl_d);
}

module prong_grab_relief() {
  m = 0.3;
  z_span = 1.0;
  y_span = 5.6;
  translate([prong_grab_face_l - prong_grab_shave, -y_span / 2, prong_grab_z - z_span / 2])
    cube([prong_grab_shave + m, y_span, z_span]);
  translate([prong_grab_face_r - m, -y_span / 2, prong_grab_z - z_span / 2])
    cube([prong_grab_shave + m, y_span, z_span]);
}

module isolator_ledges() {
  overlap = 0.3;
  translate(
    [
      shell_ox + wall - overlap,
      shell_oy + wall - overlap,
      ledge_z,
    ]
  )
    cube([shell_l - 2 * wall + 2 * overlap, ledge_w + overlap, ledge_h]);
  translate(
    [
      shell_ox + wall - overlap,
      shell_oy + shell_w - wall - ledge_w,
      ledge_z,
    ]
  )
    cube([shell_l - 2 * wall + 2 * overlap, ledge_w + overlap, ledge_h]);
}

function magnet_positions(len = shell_l, wid = shell_w) =
  [
    [mag_inset, mag_inset],
    [len - mag_inset, mag_inset],
    [mag_inset, wid - mag_inset],
    [len - mag_inset, wid - mag_inset],
  ];

module magnet_corner_2d(len = shell_l, wid = shell_w, extra = 0) {
  for (p = magnet_positions(len, wid)) {
    cx = p[0] < len / 2 ? -extra : len + extra;
    cy = p[1] < wid / 2 ? -extra : wid + extra;
    hull() {
      translate([p[0], p[1]])
        circle(d=mag_boss_d + 2 * extra);
      translate([cx, cy])
        circle(d=max(0.4, 2 * extra));
    }
  }
}

module magnet_bosses_case() {
  z0 = hook_h + shell_h - mag_boss_h;
  intersection() {
    translate([shell_ox, shell_oy, z0])
      rounded_cube([shell_l, shell_w, mag_boss_h], hook_r);
    translate([shell_ox, shell_oy, z0 - eps])
      linear_extrude(height=mag_boss_h + 2 * eps)
        magnet_corner_2d(shell_l, shell_w);
  }
}

module magnet_pockets_case() {
  for (p = magnet_positions(shell_l, shell_w))
    translate(
      [
        shell_ox + p[0],
        shell_oy + p[1],
        hook_h + shell_h - mag_pocket_h,
      ]
    )
      cylinder(h=mag_pocket_h + 1, d=mag_pocket_d);
}

module magnet_pockets_lid() {
  for (p = magnet_positions(shell_l, shell_w))
    translate([p[0], p[1], -eps])
      cylinder(h=mag_pocket_h + eps, d=mag_pocket_d);
}

module magnet_disc() {
  color([0.75, 0.78, 0.82, 0.95])
    cylinder(h=mag_h, d=mag_d);
}

module magnet_preview_case() {
  for (p = magnet_positions(shell_l, shell_w))
    translate(
      [
        shell_ox + p[0],
        shell_oy + p[1],
        hook_h + shell_h - mag_h - 0.05,
      ]
    )
      magnet_disc();
}

module magnet_preview_lid() {
  for (p = magnet_positions(shell_l, shell_w))
    translate([p[0], p[1], 0.05])
      magnet_disc();
}

module lid() {
  if (part == 1)
    lid_for_print();
  else
    translate([shell_ox, shell_oy, hook_h + shell_h])
      lid_body();
}

module lid_for_print() {
  translate([0, shell_w, lid_h])
    rotate([180, 0, 0])
      lid_body();
}

module lid_body() {
  difference() {
    rounded_cube([shell_l, shell_w, lid_h], hook_r);
    magnet_pockets_lid();
  }
  if (show_magnet_preview)
    magnet_preview_lid();
}

module rounded_cube(size, r) {
  x = size[0];
  y = size[1];
  z = size[2];
  rr = min(r, x / 2 - 0.05, y / 2 - 0.05);
  linear_extrude(height=z)
    translate([rr, rr])
      offset(r=rr)
        square([x - 2 * rr, y - 2 * rr]);
}
