make SRC_ROM="Zelda II - The Adventure of Link (USA).nes" TGT_NAME=z2mmc5
@IF ERRORLEVEL 1 GOTO failure

@echo.
@echo Success!
@goto :endbuild

:failure
@echo.
@echo Build error!

:endbuild