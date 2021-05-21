local name = std.extVar('name');
local source = std.extVar('source');
local components = std.parseJson(std.extVar('components'));
local global_vars = std.parseJson(std.extVar('global_vars'));
local imports = std.parseJson(std.extVar('imports'));

std.manifestYamlDoc({
  "import": imports,
  "vars": global_vars,
  "components": {
    "terraform": {
      [ name ]: {
        "settings": components,
        "vars": {
          "source": source,
        },
      }
    },
  },
}, indent_array_in_object=false)
