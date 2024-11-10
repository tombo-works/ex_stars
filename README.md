# ExSTARS

[![hex](https://img.shields.io/hexpm/v/ex_stars.svg)](https://hex.pm/packages/ex_stars)
[![CI](https://github.com/tombo-works/ex_stars/actions/workflows/ci.yaml/badge.svg)](https://github.com/tombo-works/ex_stars/actions/workflows/ci.yaml)
[![license](https://img.shields.io/hexpm/l/ex_stars.svg)](https://github.com/tombo-works/ex_stars/blob/main/REUSE.toml)
[![REUSE](https://api.reuse.software/badge/github.com/tombo-works/ex_stars)](https://api.reuse.software/info/github.com/tombo-works/ex_stars)

Elixir STARS library.

## STARS References

- WEB: https://stars.kek.jp/
  - [STARS tutorial](https://stars.kek.jp/lib/exe/fetch.php?media=stars_tutorial.pdf)
    (PDF A5, fits screen or tablet, in Japanse, Ver.1.1 27 Mar 2013, 1.67MB)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_stars` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_stars, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/ex_stars>.

## How to use

```elixir
iex(1)> ExSTARS.start_client({127, 0, 0, 1}, 6057)
:ok

11:25:56.166 [info] STARS server:
6737

iex(2)> ExSTARS.send("term1 stars")
:ok

11:25:59.456 [info] STARS server:
System>term1 Ok:

iex(3)> ExSTARS.send("System help")
:ok

11:26:02.905 [info] STARS server:
System>term1 @help flgon flgoff loadaliases listaliases loadpermission loadreconnectablepermission listnodes getversion gettime hello disconnect
```

## License

This project is licensed under the Apache-2.0 license.

And this project follows the REUSE compliance.
For more details, see the [REUSE SOFTWARE](https://reuse.software/).
