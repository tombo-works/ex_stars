# ExSTARS

[![hex](https://img.shields.io/hexpm/v/ex_stars.svg)](https://hex.pm/packages/ex_stars)
[![CI](https://github.com/tombo-works/ex_stars/actions/workflows/ci.yaml/badge.svg)](https://github.com/tombo-works/ex_stars/actions/workflows/ci.yaml)
[![license](https://img.shields.io/hexpm/l/ex_stars.svg)](https://github.com/tombo-works/ex_stars/blob/main/REUSE.toml)
[![REUSE](https://api.reuse.software/badge/github.com/tombo-works/ex_stars)](https://api.reuse.software/info/github.com/tombo-works/ex_stars)

Elixir STARS library.

## How to use

```elixir
iex(1)> ExSTARS.start_client("term1", "stars", {127, 0, 0, 1}, 6057)
:ok

09:03:53.215 [debug] 8414
System>term1 Ok:

iex(2)> ExSTARS.send("term1", "System help")
:ok

09:04:21.950 [debug] System>term1 @help flgon flgoff loadaliases listaliases loadpermission loadreconnectablepermission listnodes getversion gettime hello disconnect
```

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

## STARS References

- WEB: https://stars.kek.jp/
  - [STARS tutorial](https://stars.kek.jp/lib/exe/fetch.php?media=stars_tutorial.pdf)
    (PDF A5, fits screen or tablet, in Japanse, Ver.1.1 27 Mar 2013, 1.67MB)

## License

This project is licensed under the Apache-2.0 license.

And this project follows the REUSE compliance.
For more details, see the [REUSE SOFTWARE](https://reuse.software/).
