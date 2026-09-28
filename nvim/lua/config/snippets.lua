local M = {}
function M.setup()
  local ls = require("luasnip")
  local s, t, i = ls.snippet, ls.text_node, ls.insert_node
  ls.add_snippets("verilog", {
    s("modg", {
      t("module "),
      i(1, "module_name"),
      t({ " (", "    input wire clk,", "    input wire n_rst", ");", "    " }),
      i(0),
      t({ "", "endmodule" }),
    }),
    s("seqg", {
      t({ "always @(posedge clk or negedge n_rst) begin", "    if (!n_rst) begin", "        " }),
      i(1, "q <= 0;"),
      t({ "", "    end else begin", "        " }),
      i(2, "q <= d;"),
      t({ "", "    end", "end" }),
    }),
  })
  ls.filetype_extend("systemverilog", { "verilog" })
  ls.add_snippets("c", {
    s("mainbare", {
      t({ "#include <stdint.h>", "", "int main(void) {", "    " }),
      i(0),
      t({ "", "    for (;;) {}", "}" }),
    }),
  })
end
return M
