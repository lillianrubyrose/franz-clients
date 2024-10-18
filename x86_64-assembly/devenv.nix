{ pkgs, lib, config, inputs, ... }:

{
  packages = with pkgs; [ fasm clang ];
}
