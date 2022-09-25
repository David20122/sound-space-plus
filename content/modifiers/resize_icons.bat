FOR /R %%a IN (512\*.png) DO magick "%%~a" -resize 128x128 "128\%%~nxa"
FOR /R %%a IN (512\*.png) DO magick "%%~a" -resize 64x64 "64\%%~nxa"
FOR /R %%a IN (512\*.png) DO magick "%%~a" -resize 32x32 "32\%%~nxa"