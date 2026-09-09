/*
 * Variables for Thingiverse Customizer
 * ==================================================================
 *
 */

// The number of AAA cells in your battery holder
Cell_Count = 2;

// AAA cell envelope.  A standard AAA cell is approximately 44.5 mm long
// and 10.5 mm in diameter.  The extra 0.3 mm on the diameter provides
// clearance for normal FDM print variation and battery wrappers.
Cell_Length = 44.5;
Cell_Diameter = 10.8;
Cell_Pitch = 11.5;       // 0.7 mm divider between adjacent cradles
Floor_Thickness = 5;
Base_Thickness = 10;
Cell_Center_Z = Floor_Thickness + Cell_Diameter / 2;
Cell_Top_Z = Floor_Thickness + Cell_Diameter;
Box_Length = Cell_Length + 16;

// Contact shown in battery-contacts.png.  Keep the original holder's open
// insertion slot: the 10 x 10 mm plate slides in through this side opening.
// 0.2 mm clearance per side accommodates FDM print variation.
Contact_Plate_Size = 10;
Contact_Clearance = 0.2;
Contact_Pocket_Size = Contact_Plate_Size + 2 * Contact_Clearance;
Contact_Slot_Height = Contact_Plate_Size + 1.2;
Contact_Projection = 4.5;
Contact_Slot_Center_Z = Floor_Thickness + Contact_Slot_Height / 2;

function cell_y(index, cells) = -cells * Cell_Pitch / 2 + Cell_Pitch / 2 + Cell_Pitch * index;


/*
 * Library function: edge
 * ==================================================================
 *
 * Used to make roundes edges on objects
 *
 */
module edge(radius, height)
{
	difference()
	{
		translate([radius/2-0.5, radius/2-0.5, 0])
			cube([radius+1, radius+1, height], center = true);

		translate([radius, radius, 0])
			cylinder(h = height+1, r1 = radius, r2 = radius, center = true, $fn = 100);
	}
}

module battery_box(cells)
{
	difference()
	{
		union()
		{
			translate([0, 0, Base_Thickness/2])
				cube(size=[Box_Length, Cell_Pitch*cells, Base_Thickness], center=true);
	
			translate([Cell_Length/2+7+2/2, 0, Cell_Top_Z/2])
				cube(size=[2, Cell_Pitch*cells, Cell_Top_Z], center=true);

			translate([-(Cell_Length/2+7+2/2), 0, Cell_Top_Z/2])
				cube(size=[2, Cell_Pitch*cells, Cell_Top_Z], center=true);

			translate([-(Cell_Length/2+7-3/2), 0, (Cell_Top_Z-Base_Thickness+1.5)/2+Base_Thickness/2])
				cube(size=[3, Cell_Pitch*cells, Cell_Top_Z-Base_Thickness+1.5], center=true);

			translate([(Cell_Length/2+7-3/2), 0, (Cell_Top_Z-Base_Thickness+1.5)/2+Base_Thickness/2])
				cube(size=[3, Cell_Pitch*cells, Cell_Top_Z-Base_Thickness+1.5], center=true);
			
			// mounting flanges	
			translate([Cell_Length/2-5, cells*Cell_Pitch/2+4/2, 3/2])
				cube(size=[7, 4, 3], center=true);

			translate([Cell_Length/2-5, cells*Cell_Pitch/2+4, 3/2])
				cylinder(r=7/2, h=3, center=true, $fn = 60);

			translate([-(Cell_Length/2-5), cells*Cell_Pitch/2+4/2, 3/2])
				cube(size=[7, 4, 3], center=true);

			translate([-(Cell_Length/2-5), cells*Cell_Pitch/2+4, 3/2])
				cylinder(r=7/2, h=3, center=true, $fn = 60);

			translate([Cell_Length/2-5, -(cells*Cell_Pitch/2+4/2), 3/2])
				cube(size=[7, 4, 3], center=true);

			translate([Cell_Length/2-5, -(cells*Cell_Pitch/2+4), 3/2])
				cylinder(r=7/2, h=3, center=true, $fn = 60);

			translate([-(Cell_Length/2-5), -(cells*Cell_Pitch/2+4/2), 3/2])
				cube(size=[7, 4, 3], center=true);

			translate([-(Cell_Length/2-5), -(cells*Cell_Pitch/2+4), 3/2])
				cylinder(r=7/2, h=3, center=true, $fn = 60);
		}
		
		for (i=[0:cells-1])
		{
			// battery cradle
			translate([0, cell_y(i, cells), Cell_Center_Z])
			rotate(90, [0, 1, 0])
				cylinder(r=Cell_Diameter/2, h=Cell_Length+4+4, center=true, $fn = 100);
			
			// Original open contact insertion slot, scaled for a 10 x 10 mm
			// plate.  The narrow vertical slit keeps the contact captive while
			// the wider opening provides the installation path.
			translate([Cell_Length/2+7-1/2, cell_y(i, cells), Cell_Center_Z])
				cube(size=[1, 5.5, 30], center=true);

			translate([Cell_Length/2+7-1.4/2, cell_y(i, cells), Contact_Slot_Center_Z])
				cube(size=[1.4, Contact_Pocket_Size, Contact_Slot_Height], center=true);

			translate([-(Cell_Length/2+7-1/2), cell_y(i, cells), Cell_Center_Z])
				cube(size=[1, 5.5, 30], center=true);

			translate([-(Cell_Length/2+7-1.4/2), cell_y(i, cells), Contact_Slot_Center_Z])
				cube(size=[1.4, Contact_Pocket_Size, Contact_Slot_Height], center=true);

			// Original bottom solder relief, retained so the contact tail and
			// wiring remain accessible from below after installation.
			translate([(Cell_Length/2+7-7/2), cell_y(i, cells), 3/2])
				cube(size=[7, 5.5, 3.1], center=true);

			translate([(Cell_Length/2), cell_y(i, cells), 3/2])
				cylinder(r=5.5/2, h=3.1, center=true, $fn = 50);

			translate([-(Cell_Length/2+7-7/2), cell_y(i, cells), 3/2])
				cube(size=[7, 5.5, 3.1], center=true);

			translate([-(Cell_Length/2), cell_y(i, cells), 3/2])
				cylinder(r=5.5/2, h=3.1, center=true, $fn = 50);

			// polarity marking (+)
			translate([Cell_Length/2-5, cell_y(i, cells), 4/2+4.5])
				cube(size=[6, 2, 4], center=true);

			translate([Cell_Length/2-5, cell_y(i, cells), 4/2+4.5])
				cube(size=[2, 6, 4], center=true);

			// polarity marking (-)
			translate([-(Cell_Length/2-5), cell_y(i, cells), 4/2+4.5])
				cube(size=[6, 2, 4], center=true);
		}
		
		if (cells>=2)
		{
			for (i=[0:cells-2])
			{
				// bottom cut-out for cell connections
				translate([0, -cells*Cell_Pitch/2+Cell_Pitch+Cell_Pitch*i, 2.5/2])
				rotate(17, [0, 0, 1])
					cube(size=[Cell_Length, 2, 2.6], center=true);			
			}
		}
		
		// bottom cut-out for output wires
		translate([Cell_Length/4, cell_y(0, cells), 2.5/2])
			cube(size=[Cell_Length/2, 2, 2.6], center=true);			

		translate([3/2, cell_y(0, cells)+1, 2.5/2])
			edge(4, 2.6);

		translate([3/2, cell_y(0, cells)-1, 2.5/2])
		rotate(-90, [0, 0, 1])
			edge(4, 2.6);

		translate([-Cell_Length/4, cell_y(cells-1, cells), 2.5/2])
			cube(size=[Cell_Length/2, 2, 2.6], center=true);			
	
		translate([-3/2, cell_y(cells-1, cells)+1, 2.5/2])
		rotate(90, [0, 0, 1])
			edge(4, 2.6);

		translate([-3/2, cell_y(cells-1, cells)-1, 2.5/2])
		rotate(180, [0, 0, 1])
			edge(4, 2.6);

		// bottom polarity marking (+)
		translate([7, cell_y(0, cells)-4.5, 1.5/2])
			cube(size=[4, 1.5, 1.6], center=true);

		translate([7, cell_y(0, cells)-4.5, 1.5/2])
			cube(size=[1.5, 4, 1.6], center=true);

		// bottom polarity marking (-)
		translate([-7, cell_y(cells-1, cells)+4.5, 1.5/2])
			cube(size=[4, 1.5, 1.6], center=true);
		
		// mounting holes
		translate([Cell_Length/2-5, cells*Cell_Pitch/2+4, 3/2])
			cylinder(r=3.3/2, h=4, center=true, $fn = 30);

		translate([-(Cell_Length/2-5), cells*Cell_Pitch/2+4, 3/2])
			cylinder(r=3.3/2, h=4, center=true, $fn = 30);

		translate([Cell_Length/2-5, -(cells*Cell_Pitch/2+4), 3/2])
			cylinder(r=3.3/2, h=4, center=true, $fn = 30);

		translate([-(Cell_Length/2-5), -(cells*Cell_Pitch/2+4), 3/2])
			cylinder(r=3.3/2, h=4, center=true, $fn = 30);

		// bottom cut-out for output wire
		translate([0, 0, 2.5/2])
			cube(size=[3, cells*Cell_Pitch+5, 2.6], center=true);

		// cutout to ease battery removal
		translate([0, 0, Cell_Top_Z])
		rotate(90, [1, 0, 0])
			cylinder(r=Cell_Diameter/2+2.5, h=cells*Cell_Pitch+5, center=true, $fn = 100);
		
		// rounded corners on end plates
		translate([0, -cells*Cell_Pitch/2, Cell_Top_Z])
		rotate(90, [0, 1, 0])
			edge(4, Box_Length+5);

		translate([0, cells*Cell_Pitch/2, Cell_Top_Z])
		rotate(90, [0, 1, 0])
		rotate(-90, [0, 0, 1])
			edge(4, Box_Length+5);

		translate([0, -cells*Cell_Pitch/2, Cell_Top_Z-3.5])
		rotate(90, [0, 1, 0])
			edge(3, Cell_Length+7+7);

		translate([0, cells*Cell_Pitch/2, Cell_Top_Z-3.5])
		rotate(90, [0, 1, 0])
		rotate(-90, [0, 0, 1])
			edge(3, Cell_Length+7+7);
	}
}

battery_box(Cell_Count);
