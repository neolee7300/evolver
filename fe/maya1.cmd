// maya1.cmd   -  first crude version, using separate mesh for each facet.

/* Surface Evolver script to write Maya ASCII file.
   Reference: http://caad.arch.ethz.ch/info/maya/manual/FileFormats/index.html
   Also in Maya documentation:
      Developer Resources > File Formats > Maya ASCII file format > Maya ASCII file format >  
          Organizationof Maya Ascii files
   Usage:
    Enter command: read "maya1.cmd"
    Enter command: maya1 >>> "filename.ma"

   Note: The default length unit is cm, but if you want to use something
   different, then set the maya_length_unit variable to the appropriate string
   after loading maya.cmd and before running the maya command,
   e.g.

    Enter command: maya_length_unit := "in"
    Enter command: maya >>> "filename.ma"

   Valid length unit strings are:
    "mm", "millimeter", "cm", "centimeter", "m", "meter", "km", "kilometer", 
    "in", "inch", "ft", "foot", "yd", "yard", "mi", "mile".

   Note: To prevent names generated by this script from conflicting with existing
     maya names or names from another datafile, there is a string variable 
     maya_name that is prepended to all names generated by this script.
     There is a maya namespace feature that probably could be used in place
     of this, but I do not understand it yet.  The maya_name default is "AAA";
     I didn't use the datafilename since this may contain illegal characters
     and would prevent generating multiple maya objects from the same datafile.
     So if you are going to use multiple surfaces simultaneously, change
     maya_name before executing the maya command.
*/

maya_length_unit := "cm"
maya_name := "AAA"

// Evolver's RGB color components; index is color+1
define rgb_maya integer[16][3];
rgb_maya[1][1] := 0; rgb_maya[1][2] := 0; rgb_maya[1][3] := 0;
rgb_maya[2][1] := 0; rgb_maya[2][2] := 0; rgb_maya[2][3] := 255;
rgb_maya[3][1] := 0; rgb_maya[3][2] := 255; rgb_maya[3][3] := 0;
rgb_maya[4][1] := 0; rgb_maya[4][2] := 255; rgb_maya[4][3] := 255;
rgb_maya[5][1] := 255; rgb_maya[5][2] := 0; rgb_maya[5][3] := 0;
rgb_maya[6][1] := 255; rgb_maya[6][2] := 0; rgb_maya[6][3] := 255;
rgb_maya[7][1] := 255; rgb_maya[7][2] := 127; rgb_maya[7][3] := 0;
rgb_maya[8][1] := 160; rgb_maya[8][2] := 160; rgb_maya[8][3] := 160;
rgb_maya[9][1] := 80; rgb_maya[9][2] := 80; rgb_maya[9][3] := 80;
rgb_maya[10][1] := 80; rgb_maya[10][2] := 200; rgb_maya[10][3] := 255;
rgb_maya[11][1] := 127; rgb_maya[11][2] := 255; rgb_maya[11][3] := 127;
rgb_maya[12][1] := 127; rgb_maya[12][2] := 255; rgb_maya[12][3] := 255;
rgb_maya[13][1] := 255; rgb_maya[13][2] := 127; rgb_maya[13][3] := 127;
rgb_maya[14][1] := 255; rgb_maya[13][2] := 127; rgb_maya[13][3] := 255;
rgb_maya[15][1] := 255; rgb_maya[15][2] := 255; rgb_maya[15][3] := 0;
rgb_maya[16][1] := 255; rgb_maya[16][2] := 255; rgb_maya[16][3] := 255;

maya1 := {

  // Header section.  Just comments.
  printf "//Maya ASCII 2009 scene\n";   // required first six bytes
  printf "// Maya file created from Surface Evolver datafile %s\n",datafilename;
  printf "// Date: %s\n",date_and_time;

  // File reference section. None at present.

  // Requirements section.  No special requirements that I know of.
  printf "requires maya \"2009\";\n";

  // Units section.  User might have to edit this, since Evolver doesn't
  // know.  Using centimeter as default length unit.
  printf "currentUnit -l \"%s\";\n",maya_length_unit;

  // File information section.  Try some home-grown ones.
  printf "fileInfo \"datafile\"  \"%s\";\n",datafilename;
  printf "fileInfo \"generator program\"  \"Surface Evolver\";\n";
  printf "fileInfo \"generator script\"  \"maya.cmd\";\n";

  // Main section.  Nodes, attributes, and parenting.

  // One transform node for the whole surface
  printf "createNode transform -n \"%sSurface\";\n",maya_name;

  // One mesh node per facet.  Should be a way to use one mesh node
  // for bunch of facets, but I haven't been able to generate an
  // example yet.
  printf "\n // One mesh per facet. \n\n";
  foreach facet ff where show and color >= 0  do
  { printf "createNode mesh -n \"%sShape%d\" -p \"%sSurface\";\n",maya_name,ff.id,maya_name;
    printf "    setAttr -k off \".v\";\n";
    printf "    setAttr \".vir\" yes;\n";
    printf "    setAttr \".vif\" yes;\n";
    printf "    setAttr \".uvst[0].uvsn\" -type \"string\" \"map1\";\n";
    printf "    setAttr \".cuvs\" -type \"string\" \"map1\";\n";
    printf "    setAttr \".dcc\" -type \"string\" \"Ambient+Diffuse\";\n";
    printf "    setAttr \".covm[0]\"  0 1 1;\n";
    printf "    setAttr \".cdvm[0]\"  0 1 1;\n";
    printf "    setAttr \".db\" yes;\n";
    printf "    setAttr \".bw\" 4;\n";
  };
  // One face node for each facet
  printf "\n// One polygon per facet.\n\n";
  foreach facet ff where show and color >= 0 do 
  { printf "createNode polyCreateFace -n \"%sFace%d\";\n",maya_name,ff.id;
    printf "    setAttr -s 3 \".v[0:2]\" -type \"float3\"  \n";
    foreach ff.vertex vv do 
      printf "    %f %f %f\n",vv.y,vv.z,vv.x;  // since maya has y vertical
    printf "    ;\n";
    printf "    setAttr \".l[0]\"  3;\n";
    printf "    setAttr \".tx\" 1;\n";
  };


  // Create a material for each color
  local fcolor;
  printf "\n // Material for each color \n\n";
  for ( fcolor := black ; fcolor <= white ; fcolor += 1 )
  { 
    printf "createNode materialInfo -n \"%smaterial%d\";\n",maya_name,fcolor;
    printf "createNode shadingEngine -n \"%slambert%dSG\";\n",maya_name,fcolor;
    printf "    setAttr \".ihi\" 0;\n";
    printf "    setAttr \".ro\" yes;\n";
    printf "createNode lambert -n \"%slambert%d\";\n",maya_name,fcolor;
    printf "    setAttr \".c\" -type \"float3\" %f %f %f ;\n",
      rgb_maya[fcolor+1][1]/255, rgb_maya[fcolor+1][2]/255,rgb_maya[fcolor+1][3]/255;
  };

  // And this node, just because it's in the examples I generated
  printf "\n";
  printf "createNode lightLinker -n \"%slightLinker\";\n",maya_name;
  printf "    setAttr -s %d \".lnk\";\n",facet_count;
  printf "    setAttr -s %d \".slnk\";\n",facet_count;

  // Stuff I have little clue about
  printf "\n";
  printf "select -ne :renderPartition;\n";
  printf "    setAttr -s 18 \".st\";\n"; // slots for materials? colors plus 2 defaults??
  printf "\n";
  printf "select -ne :defaultShaderList1;\n";
  printf "    setAttr -s 18 \".s\";\n";  // slots for materials?

  // Hook up facets with shapes
  printf "\n// Connect each facet with its shape.\n\n";
  foreach facet ff where show and color >= 0  do
    printf "connectAttr \"%sFace%d.out\" \"%sShape%d.i\";\n",maya_name,ff.id,
        maya_name,ff.id;

  // Materials hookup
  printf "\n// Connect color shaders with materials\n\n";
  for ( fcolor := black ; fcolor <= white ; fcolor += 1 )
  { printf "connectAttr \"%slambert%dSG.msg\" \"%smaterial%d.sg\"; \n",
       maya_name,fcolor,maya_name,fcolor;
    printf "connectAttr \"%slambert%d.msg\" \"%smaterial%d.m\"; \n",
       maya_name,fcolor,maya_name,fcolor;
    printf "connectAttr \"%slambert%d.oc\" \"%slambert%dSG.ss\"; \n",
       maya_name,fcolor,maya_name,fcolor;
  };

  // Connect facets to colors
  printf "\n// Connect facets to colors.\n\n";
  foreach facet ff where show and color >= 0  do
  { printf "connectAttr \"%sShape%d.iog\" \"%slambert%dSG.dsm\" -na;\n",
       maya_name,ff.id,maya_name,ff.color;
  };

  // More fiddling with colors
  printf "\n// More connecting up shaders and lights\n\n";
  printf "connectAttr \":defaultLightSet.msg\" \"%slightLinker.lnk[0].llnk\";\n",maya_name;
  printf "connectAttr \":initialShadingGroup.msg\" \"%slightLinker.lnk[0].olnk\";\n",maya_name;
  printf "connectAttr \":defaultLightSet.msg\" \"%slightLinker.slnk[0].sllk\";\n",maya_name;
  printf "connectAttr \":initialShadingGroup.msg\" \"%slightLinker.slnk[0].solk\";\n",maya_name;

  printf "connectAttr \":defaultLightSet.msg\" \"%slightLinker.lnk[1].llnk\";\n",maya_name;
  printf "connectAttr \":initialParticleSE.msg\" \"%slightLinker.lnk[1].olnk\";\n",maya_name;
  printf "connectAttr \":defaultLightSet.msg\" \"%slightLinker.slnk[1].sllk\";\n",maya_name;
  printf "connectAttr \":initialParticleSE.msg\" \"%slightLinker.slnk[1].solk\";\n",maya_name;

  for ( fcolor := black ; fcolor <= white ; fcolor += 1 )
  { printf "connectAttr \":defaultLightSet.msg\" \"%slightLinker.lnk[%d].llnk\";\n",
       maya_name,fcolor+2;
    printf "connectAttr \"%slambert%dSG.msg\" \"%slightLinker.lnk[%d].olnk\";\n",
       maya_name,fcolor,maya_name,fcolor+2;
    printf "connectAttr \":defaultLightSet.msg\" \"%slightLinker.slnk[%d].sllk\";\n",
       maya_name,fcolor+2;
    printf "connectAttr \"%slambert%dSG.msg\" \"%slightLinker.slnk[%d].solk\";\n",
       maya_name,fcolor,maya_name,fcolor+2;
    printf "connectAttr \"%slambert%dSG.pa\" \":renderPartition.st\" -na;\n",maya_name,fcolor;
    printf "connectAttr \"%slambert%d.msg\" \":defaultShaderList1.s\" -na;\n",maya_name,fcolor;
  };

  printf "\n// And plug lights into global list.\n";
  printf "connectAttr \"%slightLinker.msg\" \":lightList1.ln\" -na;\n",maya_name;


  printf "\n// End of file\n";

} 

// End maya1.cmd

// Usage: maya1 >>> "filename.ma"

