# Hacking

This file defines the steps to start collaborating with the development of the app.

## Fixing Dependencies

There are some depenendencies that need to be fixed to hack this application:

```
$ sudo apt install elementary-sdk
```

## Preparing the Build System

Then, to build this application, prepare the meson build system staying in your root directory:

```
$ meson build --prefix=/usr
```

This will create a `build` folder inside the main folder.

## Translation Files

Now, prepare the translation files from the `build` directory:

```
$ cd build
$ ninja com.felixbrezo.Valoro-pot
[0/1] Running external command com.felixbrezo.Valoro-pot.
```

After running this command you should notice a new file in the po directory containing all of the translatable strings for the application.
This is a template that we can use to create files for the different languages:

```
$ ninja com.felixbrezo.Valoro-update-po
[0/1] Running external command com.felixbrezo.Valoro-update-po.
Creado …/Valoro/po/es.po.
Creado …/Valoro/po/en.po.
```

Note that you may need to update the following files:

- `LINGUAS`. To set new languages by adding one per line.
- `POTFILES`. To define the files that will be explored.

Each time that a new translatable string is added to the project or that the application text changes in some way, we should regenerate the new `.pot` and `.po` files using the `-pot` and `-update-po` build targets from the previous two steps. 

To support more languages, they need to be added to the `LINGUAS` file and generate the new `.po` file with the `-update-po` command. 

## Building the Application

Whenever it's time to build the application, `cd` into the `build` folder and run `ninja:

```
$ ninja
```

The application `com.felixbrezo.Valoro` should have been built within the folder as an executable file. 

If you prefer

```
$ ninja install
``` 


