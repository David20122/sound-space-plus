# Settings Manual
I've heard people mentioning that our settings are confusing. This should, hopefully, help with that issue.

## Camera & Parallax 
**Settings:** Camera Parallax, HUD Parallax, Grid Parallax, Camera Unlock  

As you may have noticed, the way parallax and camera lock works in SS+ is a lot more complex than Sound Space.  

Essentially, parallax is what causes the game to move with your cursor, giving you a sort of artificial depth perception.  
Camera lock refers to how the camera always faces forward, and spin, or unlocked camera, is when the camera rotates to point at the cursor.

### Parallax Types
- **Camera:** Camera parallax moves the actual camera, which affects the entire game world, including the HUD, notes, and background. (This is essentially added on top of your HUD and Grid parallax.)
- **HUD:** HUD parallax moves only the UI elements surrounding the grid.
- **Grid:** Grid parallax moves the notes and the grid they pass through. If you want a closer experience to Sound Space, you'll want this to be higher than your HUD parallax.

Keep in mind that you can make any of these values negative! Also, parallax currently doesn't apply if Camera Unlock is turned on.

### Sound Space camera modes
**Full Lock:**
- Camera Parallax: 0
- HUD Parallax: 0
- Grid Parallax: 0
- Camera Unlock: off

**Half Lock (default settings):**
- Camera Parallax: 1
- HUD Parallax: 0.2
- Grid Parallax: 3
- Camera Unlock: off

**Spin:**
- Camera Parallax: N/A
- HUD Parallax: N/A
- Grid Parallax: N/A
- Camera Unlock: on

## Approach & Note Display
**Settings:** Approach Rate, Spawn Distance, Fade Length, Note Spawn Effect, Block Colors, Note Mesh  

*NOTE: All distance/speed values (usually specified as meters) should be half of what they would be in Vulnus and Sound Space.*  

Approach Rate (AR) is the speed that notes move towards the grid.  
Spawn Distance (SD) is the distance from the grid that notes play spawn effects (if enabled) and start fading in.  
Spawn effects are the beams of light that appear when a note reaches your spawn distance.  

Fade Length is the percentage of the distance from spawn to grid that notes take to fade from invisible to fully opaque.  
For example, with a spawn distance of 40m and a fade length of 75%, notes would start fully transparent and would reach full opacity when they reached 10m from the grid.  
To disable the fade-in effect completely, set your Fade Length to 0%.  

Keep in mind that the Nearsighted modifier overrides your spawn distance and fade length, and that both Nearsighted and Ghost take your approach rate into account when calculating the fade distances to ensure that they are always visible for the same amount of time.  

### Converting from Vulnus spawn values
To convert from Vulnus approach settings, set your spawn distance to half of your Vulnus approach distance.  
Then, divide your new spawn distance by your approach time, and set that as your approach rate.  

**As equations:**  
`SD = AD * 0.5`  
`AR = (AD * 0.5) / AT`  
(Note: SD and AR refer to the previously mentioned SS+ settings, and AD and AT refer to Vulnus's Approach Distance and Time, respectively)
