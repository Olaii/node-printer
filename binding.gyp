{
  'variables': {
    'module_name': 'node-printer',
    'module_path': 'lib/binding/'
  },
  'targets': [
      {
      "target_name": "action_after_build",
      "type": "none",
      "dependencies": [ "<(module_name)" ],
      "copies": [
        {
          "files": [ "<(PRODUCT_DIR)/<(module_name).node" ],
          "destination": "<(module_path)"
        }
      ]
    },
    {
      'target_name': '<(module_name)',
      'sources': [
        'src/node_printer.cc',
        'src/hello_world.cc'
      ],
      'conditions': [
        ['OS=="win"', {
          'sources': [ 'src/node_printer_win.cc' ],
        }],
        ['OS=="mac"', {
          'sources': [ 'src/node_printer_posix.cc' ],
          'link_settings': { 'libraries': [ '-lcups' ] }
        }],
        ['OS=="linux"', {
          'sources': [ 'src/node_printer_posix.cc' ],
          'link_settings': { 'libraries': [ '-lcups' ] }
        }]
      ],
      'include_dirs': ["<!@(node -p \"require('node-addon-api').include\")"],
      'dependencies': ["<!(node -p \"require('node-addon-api').gyp\")"],
      'cflags!': [ '-fno-exceptions' ],
      'cflags_cc!': [ '-fno-exceptions' ],
      'xcode_settings': {
        'GCC_ENABLE_CPP_EXCEPTIONS': 'YES',
        'CLANG_CXX_LIBRARY': 'libc++',
        'MACOSX_DEPLOYMENT_TARGET': '10.7'
      },
      'msvs_settings': {
        'VCCLCompilerTool': { 'ExceptionHandling': 1 },
      }
    }
  ]
}
