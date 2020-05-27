# project name and programming language
project('com.felixbrezo.Valoro', 'vala', 'c')

# Include the translations module
i18n = import('i18n')

# Set our translation domain
add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

# create a new executable file, list the files we want to compile, list deps and install
executable(
  meson.project_name(),
  'src/Application.vala',
  'src/Window.vala',
  'src/Utils/AccountingEntry.vala',
  'src/Utils/Asset.vala',
  'src/Utils/Movement.vala',
  'src/Utils/Numbers.vala',
  'src/Utils/Operation.vala',
  'src/Views/WelcomeView.vala',
  'src/Views/MainView.vala',
  'src/Views/NewLogbookView.vala',
  'src/Widgets/AssetDialog.vala',
  'src/Widgets/AssetPanel.vala',
  'src/Widgets/HeaderBar.vala',
  'src/Widgets/OperationDialog.vala',
  'src/Widgets/AccountingTable.vala',
  'src/Widgets/OperationsTable.vala',
  'src/Widgets/SettingsMenu.vala',
  dependencies: [
    dependency('granite'),
    dependency('json-glib-1.0'),
    dependency('gee-0.8')
  ],
  install: true
)

#Translate and install our .desktop file
i18n.merge_file(
    input: join_paths('data', meson.project_name() + '.desktop.in'),
    output: meson.project_name() + '.desktop',
    po_dir: join_paths(meson.source_root(), 'po'),
    type: 'desktop',
    install: true,
    install_dir: join_paths(get_option('datadir'), 'applications')
)

#Translate and install our .appdata file
i18n.merge_file(
    input: join_paths('data', meson.project_name() + '.appdata.xml.in'),
    output: meson.project_name() + '.appdata.xml',
    po_dir: join_paths(meson.source_root(), 'po'),
    install: true,
    install_dir: join_paths(get_option('datadir'), 'metainfo')
)

subdir('po')
