return {
  "williamboman/mason.nvim",
  lazy = false, -- beim Start laden
  priority = 900, -- früh laden
  opts = {
    registries = {
      "github:mason-org/mason-registry",
      "github:Crashdummyy/mason-registry",
    },
  },
}
