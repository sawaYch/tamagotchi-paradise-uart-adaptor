// Tamagotchi Paradise wireless UART adapter
// Hook (Basic_rev2.stl) + ESP32-WROOM-32E PCB + magnetic power tray + cover.

$fn = 64;
eps = 0.05;

tolerance = 0.2;
show_board_preview = false;
show_pin_preview = false;
show_magnet_preview = false;

// 0 = adapter, 1 = power tray, 2 = assembled, 3 = tray cover
// Use a number so `openscad -D part=0` works on Windows (no quoted strings).
part = 2;

// --- tama_bridge ESP32-WROOM-32E (20 x 31.35 mm FR4, antenna overhang 6.25) ---
pcb_l = 31.35;
pcb_w = 20.0;
pcb_thickness = 1.6;
ant_keepout = 6.25;
module_l = 25.5;
module_w = 18.0;
module_h = 3.2;
pcb_h = pcb_thickness + module_h;
btn_l = 3.9;
btn_w = 3.0;
btn_h = 2.5;
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

// Bluetooth-symbol window on the free (+X) antenna wall
ble_symbol_h = 9.0;
ble_symbol_stroke = 1.35;

// Space under the PCB: solder fillet + 24 AWG + user-added isolator sheet
solder_h = 1.0;
wire_od = 1.4;
isolator_h = 1.0;
solder_well_h = solder_h + wire_od;
board_lift = solder_well_h + isolator_h;
ledge_w = 1.8;
ledge_h = min_wall;

// 5 x 2 mm N52 discs at the four top corners. PCB slides in from the
// antenna wall under these, so the outer box stays a clean rectangle.
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

// Female pogo housing in tray floor (ears seat on a ledge, insert from the lid cavity)
fp_body_l = 12.5;
fp_ear_l = 14.5;
fp_w = 4.0;
fp_h = 4.0;
fp_ear_t = 1.0;
fp_fit = 0.2;

// --- Power tray components ---
// 102535 LiPo 1000 mAh
batt_l = 35.0;
batt_w = 25.0;
batt_t = 10.0;
// MiniUPS-3.3V
ups_l = 35.0;
ups_w = 21.0;
ups_t = 5.6;
// SS-12D10-G5 slide switch
sw_l = 12.7;
sw_w = 6.7;
sw_h = 11.3;
sw_body_h = 6.5;
sw_act_travel = 2.2;
sw_act_l = 11.5;
sw_act_h = 4.2;
// Vertical USB-C opening on the +X end wall (plug long axis along Z).
// Insets are from the outer case to the opening edges.
usbc_w = 3.6;
usbc_h = 9.5;
usbc_side_inset = 3.5;
usbc_top_inset = 16.0;
// Status-LED grille just above that opening
led_hole_d = 1.5;
led_hole_pitch = 2.5;
led_hole_cols = 5;
led_hole_rows = 3;
led_hole_gap = 1.6;

comp_fit = 0.4;
// Battery stands on its thin face so tray width can match the adapter:
// footprint 35(L)×10(T), height 25(W) — makes the lid taller.
batt_bay_l = batt_l + comp_fit;
batt_bay_w = batt_t + comp_fit;
batt_bay_h = batt_w + comp_fit;
ups_pl = ups_l + comp_fit;
ups_pw = ups_w + comp_fit;
ups_pt = ups_t + 0.2;
sw_pl = sw_l + 0.4;
sw_pw = sw_w + 0.3;

tray_roof = 0.8;
tray_floor = fp_h + tray_roof;
// Air above MiniUPS; keeps the USB-C / LED windows on the +X wall
tray_lip = mag_boss_h + 0.4;
tray_gap_sw = 0.6;
tray_inner_l = max(batt_bay_l, ups_pl) + 1.0;
tray_cavity_h = batt_bay_h + ups_pt + tray_lip;
tray_h = tray_floor + tray_cavity_h;
cover_h = mag_pocket_h + mag_floor;
cover_pry_w = 10.0;
cover_pry_d = 1.2;
pogo_wire_slot_w = 2.2;
pogo_wire_slot_l = 6.0;

// Kuchipatchi outline on the plain long wall, opposite the slide switch.
kuchipatchi_margin_z = 2.6;
kuchipatchi_depth = 0.4;
// Height of kuchipatchi.svg as imported, in mm.
kuchipatchi_art_h = 34.75;

// Paradise wordmark on the switch side, centered on that wall.
paradise_margin_x = 2.8;
paradise_depth = 0.4;
// Width of paradise-logo.svg as imported, in mm.
paradise_art_w = 36.70;

// --- Hook reinforcement (imported Basic_rev2.stl) ---
prong_root_y = -2.5;
prong_root_w = 5.0;
prong_root_depth = 3.45;
prong_root_extra = 1.25;
prong_root_overlap = 0.25;

// Detent faces that clip the Tamagotchi's grab bar (measured from STL)
prong_grab_shave = 0.1;
prong_grab_face_l = -7.112;
prong_grab_face_r = -4.888;
prong_grab_z = -2.49;

grab_cyl_x = 6.0;
grab_cyl_z = -0.20;
grab_cyl_d = 2.64; // original = ~2.4mm
grab_cyl_len = 5.7;

// --- Derived ---
pcb_cav_l = pcb_l + ant_keepout + 2 * tolerance;
pcb_cav_w = max(pcb_w + 2 * tolerance, ups_pw);
pcb_cav_h = max(pcb_h, pcb_thickness + sw_body_h) + tolerance + headroom;
shell_h = wall + board_lift + pcb_cav_h + shell_extra;

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

tray_l = max(tray_inner_l + 2 * wall, shell_l);
// Match adapter width (no Y overhang); height grows instead
tray_w = shell_w;
mate_ox = 0;
mate_oy = 0;
// Stack flush to the +X free wall so MiniUPS USB-C reaches the cutout
batt_x = tray_l - wall - batt_bay_l;
batt_y = wall;
ups_x = tray_l - wall - ups_pl;
ups_y = (tray_w - ups_pw) / 2;
sw_x = wall + (tray_l - 2 * wall - sw_pl) / 2;
sw_y = wall + batt_bay_w + tray_gap_sw;

// Pad edge toward the hook / pogo pins; antenna toward the free (+X) wall
board_x0 = hook_x0 + wall + tolerance;
board_y0 = -pcb_w / 2;

pin_barrel_hole = pin_barrel_d + 2 * pin_hole_clear;
pin_flange_hole = pin_flange_d + 2 * pin_hole_clear;
pin_floor_z = hook_h + wall;
pin_seat_z = pin_floor_z - pin_flange_h;
pcb_z = pin_floor_z + board_lift;
ledge_z = pin_floor_z + solder_well_h - ledge_h;

if (part == 1) {
  lid();
} else if (part == 3) {
  tray_cover();
} else {
  adapter();
  if (part == 2) {
    color([0.25, 0.55, 0.85, 0.72])
      lid();
    color([0.35, 0.65, 0.45, 0.72])
      tray_cover();
  }
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
        pcb_insert_slot();
        ble_engrave();
        mode_switch_slot();
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

module pcb_insert_slot() {
  slot_w = pcb_w + 2 * tolerance + 0.4;
  slot_h = pcb_h + 2 * tolerance + 0.8;
  slot_z = pcb_z - 0.25;
  r = min(1.2, slot_h / 2 - 0.15, slot_w / 2 - 0.15);
  translate([shell_ox + shell_l - wall - 1, 0, slot_z + slot_h / 2])
    rotate([0, 90, 0])
      linear_extrude(height=wall + 2)
        offset(r=r)
          square([slot_h - 2 * r, slot_w - 2 * r], center=true);
}

module ble_engrave() {
  h = 4.0;
  z0 = hook_h + shell_h - 2.6;
  translate([shell_ox + shell_l + eps, 0, z0])
    rotate([0, -90, 0])
      linear_extrude(height=0.4 + eps)
        rotate([0, 0, 90])
          mirror([0, 1])
            bluetooth_symbol_strokes(h, 0.65);
}

// BLE/SPP mode SS-12D10 on the hook (-X) end wall. Body rests just above
// the pad edge of the PCB; actuator slot matches the lid power switch.
module mode_switch_slot() {
  slot_w = sw_act_l + sw_act_travel;
  slot_h = sw_act_h;
  r = min(1.0, slot_w / 2 - 0.2, slot_h / 2 - 0.2);
  zc = pcb_z + pcb_thickness + tolerance + sw_body_h / 2;
  translate([shell_ox - 0.2, 0, zc])
    rotate([0, 90, 0])
      linear_extrude(height=wall + 2)
        offset(r=r)
          square([slot_h - 2 * r, slot_w - 2 * r], center=true);
}

module ble_symbol_window(x0, z0, tilt, spin, depth, flip=false) {
  translate([x0, 0, z0])
    rotate([0, tilt, 0])
      linear_extrude(height=depth)
        rotate([0, 0, spin])
          if (flip)
            mirror([0, 1])
              bluetooth_symbol_2d(ble_symbol_h, ble_symbol_stroke);
          else
            bluetooth_symbol_2d(ble_symbol_h, ble_symbol_stroke);
}

// Classic Bluetooth rune: vertical stem, right-pointing B bowls, left X arms.
// Close gaps narrower than min_wall so the window leaves no thin ribs.
module bluetooth_symbol_2d(height, stroke) {
  difference() {
    offset(r=-min_wall / 2)
      offset(r=min_wall / 2)
        bluetooth_symbol_strokes(height, stroke);
    bluetooth_symbol_bridges(height, stroke);
  }
}

module bluetooth_symbol_strokes(height, stroke) {
  h = height;
  t = stroke;
  tip_x = h * 0.40;
  mid_y = h * 0.06;
  union() {
    bluetooth_bar([0, h / 2], [0, -h / 2], t);
    bluetooth_bar([0, h / 2], [tip_x, mid_y], t);
    bluetooth_bar([tip_x, mid_y], [0, -mid_y], t);
    bluetooth_bar([0, mid_y], [tip_x, -mid_y], t);
    bluetooth_bar([tip_x, -mid_y], [0, -h / 2], t);
    bluetooth_bar([-tip_x, h * 0.34], [0, 0], t);
    bluetooth_bar([-tip_x, -h * 0.34], [0, 0], t);
  }
}

module bluetooth_symbol_bridges(height, stroke) {
  h = height;
  t = stroke;
  tip_x = h * 0.40;
  mid_y = h * 0.06;
  support_len = t + h * 0.28;
  bluetooth_perp_support(0, h / 2, tip_x, mid_y, support_len, min_wall);
  bluetooth_perp_support(tip_x, -mid_y, 0, -h / 2, support_len, min_wall);
}

module bluetooth_perp_support(ax, ay, bx, by, len, w) {
  mx = (ax + bx) / 2;
  my = (ay + by) / 2;
  dx = bx - ax;
  dy = by - ay;
  nlen = sqrt(dx * dx + dy * dy);
  nx = -dy / nlen;
  ny = dx / nlen;
  bluetooth_bar(
    [mx - nx * len / 2, my - ny * len / 2],
    [mx + nx * len / 2, my + ny * len / 2],
    w
  );
}

module bluetooth_bar(a, b, t) {
  hull() {
    translate(a) circle(d=t, $fn=24);
    translate(b) circle(d=t, $fn=24);
  }
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
  // KiCad: pads at y=37.6, antenna keepout y=0..6.25. Mapped so +X is antenna.
  kicad_y1 = pcb_l + ant_keepout;
  kicad_mod_x = 10.0;
  kicad_mod_y0 = 0.31;
  kicad_sw_y = 28.25;
  kicad_led_x = 11.35;
  kicad_led_y = 31.05;
  pad_y = 36.15;
  pad_xs = [1.7, 3.55, 5.4, 7.45, 9.3, 11.15, 13.15, 15.0, 16.95, 18.8];
  led_d = 1.6;
  mod_x = board_x0 + (kicad_y1 - (kicad_mod_y0 + module_l));
  ant_x = board_x0 + (kicad_y1 - (kicad_mod_y0 + ant_keepout));
  shield_x = board_x0 + (kicad_y1 - (kicad_mod_y0 + 6.2));
  led_x = board_x0 + (kicad_y1 - kicad_led_y);
  sw_x = board_x0 + (kicad_y1 - kicad_sw_y);
  pads_x = board_x0 + (kicad_y1 - pad_y);

  translate([pcb_insert_x_offset, pcb_insert_y_offset, pcb_z])
    rotate([0, 0, board_preview_angle])
      union() {
        color([0.12, 0.42, 0.22, 0.90])
          translate([board_x0, board_y0, 0])
            cube([pcb_l, pcb_w, pcb_thickness]);

        color([0.10, 0.10, 0.10, 0.96])
          translate([mod_x, board_y0 + kicad_mod_x - module_w / 2, pcb_thickness])
            cube([module_l, module_w, module_h]);

        color([0.92, 0.92, 0.88, 0.50])
          translate([ant_x, board_y0 + 1.0, pcb_thickness + module_h])
            cube([ant_keepout - 0.3, pcb_w - 2.0, 0.05]);

        color([0.55, 0.55, 0.58, 0.90])
          translate([shield_x, -3.0, pcb_thickness + module_h])
            cube([4.0, 6.0, 0.08]);

        color([0.15, 0.85, 0.30, 0.95])
          translate([led_x, board_y0 + kicad_led_x, pcb_thickness])
            cylinder(h=0.6, d=led_d);

        color([0.25, 0.25, 0.28, 0.95]) {
          translate([sw_x - btn_w / 2, board_y0 + 5.2 - btn_l / 2, pcb_thickness])
            cube([btn_w, btn_l, btn_h]);
          translate([sw_x - btn_w / 2, board_y0 + 14.8 - btn_l / 2, pcb_thickness])
            cube([btn_w, btn_l, btn_h]);
        }

        for (px = pad_xs)
          translate([pads_x, board_y0 + px, -0.05])
            color([0.82, 0.68, 0.18, 0.95])
              cylinder(h=pcb_thickness + 0.15, d=1.4);
      }
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

module magnet_bosses_tray() {
  z0 = tray_h - mag_boss_h;
  intersection() {
    translate([0, 0, z0])
      rounded_cube([tray_l, tray_w, mag_boss_h], hook_r);
    translate([0, 0, z0 - eps])
      linear_extrude(height=mag_boss_h + 2 * eps)
        magnet_corner_2d(tray_l, tray_w);
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
    translate([mate_ox + p[0], mate_oy + p[1], 0.05])
      magnet_disc();
}

module magnet_preview_tray() {
  for (p = magnet_positions(tray_l, tray_w))
    translate([p[0], p[1], tray_h - mag_h - 0.05])
      magnet_disc();
}

module magnet_preview_cover() {
  for (p = magnet_positions(tray_l, tray_w))
    translate([p[0], p[1], 0.05])
      magnet_disc();
}

module lid() {
  if (part == 1)
    lid_for_print();
  else
    translate([shell_ox - mate_ox, shell_oy - mate_oy, hook_h + shell_h])
      lid_body();
}

module lid_for_print() {
  translate([0, tray_w, tray_h])
    rotate([180, 0, 0])
      lid_body();
}

module lid_body() {
  difference() {
    union() {
      difference() {
        rounded_cube([tray_l, tray_w, tray_h], hook_r);
        tray_cavity();
        magnet_pockets_lid();
        female_pogo_pocket();
        switch_actuator_slot();
        usbc_window();
        ups_led_window();
      }
      magnet_bosses_tray();
    }
    magnet_pockets_tray();
    kuchipatchi_engrave();
    paradise_engrave();
  }
  if (show_magnet_preview) {
    magnet_preview_lid();
    magnet_preview_tray();
  }
  if (show_pin_preview)
    female_pogo_preview();
  if (show_board_preview)
    tray_component_preview();
}

module tray_cover() {
  if (part == 3)
    tray_cover_for_print();
  else
    translate([shell_ox - mate_ox, shell_oy - mate_oy, hook_h + shell_h + tray_h])
      tray_cover_body();
}

module tray_cover_for_print() {
  translate([0, tray_w, cover_h])
    rotate([180, 0, 0])
      tray_cover_body();
}

module tray_cover_body() {
  difference() {
    rounded_cube([tray_l, tray_w, cover_h], hook_r);
    magnet_pockets_cover();
  }
  if (show_magnet_preview)
    magnet_preview_cover();
}

function female_pogo_center() =
  [mate_ox + shell_l / 2, mate_oy + shell_w / 2];

module female_pogo_2d(len, wid) {
  r = wid / 2;
  dx = max(0, len / 2 - r);
  hull() {
    translate([-dx, 0]) circle(d=wid);
    translate([dx, 0]) circle(d=wid);
  }
}

module paradise_engrave() {
  s = (tray_l - 2 * paradise_margin_x) / paradise_art_w;
  translate([tray_l / 2, tray_w + eps, tray_h / 2])
    rotate([90, 0, 0])
      linear_extrude(height=paradise_depth + eps, convexity=12)
        scale(s)
          mirror([1, 0])
            import("paradise-logo.svg", center=true, convexity=12);
}

module kuchipatchi_engrave() {
  s = (tray_h - 2 * kuchipatchi_margin_z) / kuchipatchi_art_h;
  translate([tray_l / 2, -eps, tray_h / 2])
    rotate([-90, 0, 0])
      linear_extrude(height=kuchipatchi_depth + eps, convexity=16)
        scale(s)
          mirror([0, 1])
            import("kuchipatchi.svg", center=true, convexity=16);
}

module tray_cavity() {
  translate([wall, wall, tray_floor])
    rounded_cube(
      [
        tray_l - 2 * wall,
        tray_w - 2 * wall,
        tray_cavity_h + 1,
      ],
      0.6
    );
}

module magnet_pockets_lid() {
  for (p = magnet_positions(shell_l, shell_w))
    translate([mate_ox + p[0], mate_oy + p[1], -eps])
      cylinder(h=mag_pocket_h + eps, d=mag_pocket_d);
}

module magnet_pockets_tray() {
  for (p = magnet_positions(tray_l, tray_w))
    translate([p[0], p[1], tray_h - mag_pocket_h])
      cylinder(h=mag_pocket_h + 1, d=mag_pocket_d);
}

module magnet_pockets_cover() {
  for (p = magnet_positions(tray_l, tray_w))
    translate([p[0], p[1], -eps])
      cylinder(h=mag_pocket_h + eps, d=mag_pocket_d);
}

module female_pogo_pocket() {
  c = female_pogo_center();
  bl = fp_body_l + 2 * fp_fit;
  el = fp_ear_l + 2 * fp_fit;
  w = fp_w + 2 * fp_fit;
  ear_z = (fp_h - fp_ear_t) / 2;

  // Body opening on the adapter face. Ears rest on the ledge around it.
  translate([c[0], c[1], -eps])
    linear_extrude(height=ear_z + 2 * eps)
      female_pogo_2d(bl, w);
  // Ear-width shaft from that ledge up through the floor into the lid cavity.
  translate([c[0], c[1], ear_z])
    linear_extrude(height=tray_floor - ear_z + eps)
      female_pogo_2d(el, w);
}

module pogo_wire_slot() {
  c = female_pogo_center();
  translate(
    [
      c[0] + fp_body_l / 2 - 0.5,
      c[1] - pogo_wire_slot_w / 2,
      fp_h - eps,
    ]
  )
    cube([pogo_wire_slot_l, pogo_wire_slot_w, tray_roof + 2 * eps]);
}

module switch_actuator_slot() {
  travel_pad = sw_act_travel;
  ax = sw_x + (sw_pl - sw_act_l) / 2 - travel_pad / 2;
  az = tray_floor + (min(sw_body_h, batt_bay_h) - sw_act_h) / 2;
  translate([ax, tray_w - wall - eps, az])
    cube([sw_act_l + travel_pad, wall + 2 * eps, sw_act_h]);
}

module usbc_window() {
  // Capsule on the flat +X wall: 3.5 mm from the -Y side, 16 mm from the top.
  y_c = usbc_side_inset + usbc_w / 2;
  z_top = tray_h - usbc_top_inset;
  rad = usbc_w / 2;
  z_hi = z_top - rad;
  z_lo = z_top - usbc_h + rad;
  translate([tray_l - wall - eps, y_c, 0])
    hull() {
      translate([0, 0, z_lo])
        rotate([0, 90, 0])
          cylinder(h=wall + 2 * eps, r=rad);
      translate([0, 0, z_hi])
        rotate([0, 90, 0])
          cylinder(h=wall + 2 * eps, r=rad);
    }
}

module ups_led_window() {
  z0 = tray_h - usbc_top_inset + led_hole_gap + led_hole_d / 2;
  // Start over the USB-C opening and run inward, clear of the corner fillet.
  y_left = usbc_side_inset + led_hole_d / 2;
  for (c = [0:led_hole_cols - 1], r = [0:led_hole_rows - 1])
    translate(
      [
        tray_l - wall - eps,
        y_left + c * led_hole_pitch,
        z0 + r * led_hole_pitch,
      ]
    )
      rotate([0, 90, 0])
        cylinder(h=wall + 2 * eps, d=led_hole_d);
}

module female_pogo_preview() {
  c = female_pogo_center();
  ear_z = (fp_h - fp_ear_t) / 2;
  color([0.90, 0.75, 0.20, 0.95]) {
    translate([c[0], c[1], 0])
      linear_extrude(height=fp_h)
        female_pogo_2d(fp_body_l, fp_w);
    translate([c[0], c[1], ear_z])
      linear_extrude(height=fp_ear_t)
        female_pogo_2d(fp_ear_l, fp_w);
  }
}

module tray_component_preview() {
  // Battery upright on thin face: 35×10 footprint, 25 tall
  color([0.15, 0.15, 0.18, 0.85])
    translate([batt_x + comp_fit / 2, batt_y + comp_fit / 2, tray_floor])
      cube([batt_l, batt_t, batt_w]);

  // MiniUPS: rotate 180° so local bottom-left USB-C lands on +X / -Y
  color([0.12, 0.45, 0.22, 0.90])
    translate([ups_x + ups_pl, ups_y + ups_pw, tray_floor + batt_bay_h])
      rotate([0, 0, 180])
        cube([ups_l, ups_w, ups_t]);

  // USB-C shell hint, vertical, behind the end-wall opening
  color([0.75, 0.75, 0.78, 0.95])
    translate(
      [
        tray_l - wall - 7.0,
        usbc_side_inset + (usbc_w - 3.0) / 2,
        tray_h - usbc_top_inset - usbc_h + (usbc_h - 8.8) / 2,
      ]
    )
      cube([7.0, 3.0, 8.8]);

  // SS-12D10-G5 body + actuator stub
  color([0.10, 0.10, 0.10, 0.92]) {
    translate([sw_x + 0.2, sw_y + 0.15, tray_floor])
      cube([sw_l, sw_w, sw_body_h]);
    translate(
      [
        sw_x + (sw_pl - 4.0) / 2,
        tray_w - wall - 0.2,
        tray_floor + (sw_body_h - 3.0) / 2,
      ]
    )
      cube([4.0, wall + 1.5, 3.0]);
  }
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
