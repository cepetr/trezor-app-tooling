# Trezor App Tooling

Create a development shell with the Rust toolchain and `cargo-generate`:

```sh
nix develop github:cepetr/trezor-app-tooling
```

Then generate a new app repository from the template. Replace `my-trezor-app`
with the name of the new application:

```sh
trezor-app-generate --name my-trezor-app
```

The command creates `./my-trezor-app`. Enter it with:

```sh
cd my-trezor-app
```