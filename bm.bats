#!/usr/bin/env bats

BM="${BATS_TEST_DIRNAME}/bin/bm"

setup() {
	export TMPDIR="$(mktemp -d)"
	export XDG_CONFIG_HOME="$TMPDIR/config"
	mkdir -p "$XDG_CONFIG_HOME/cdpath"
}

teardown() {
	rm -rf "$TMPDIR"
}

# helpers
cdpath_dir() { echo "$XDG_CONFIG_HOME/cdpath"; }
bookmark_target() { readlink -f "$(cdpath_dir)/$1"; }

# list

@test "list: empty cdpath prints nothing" {
	run "$BM"
	[ "$status" -eq 0 ]
	[ -z "$output" ]
}

@test "list: shows bookmark name and resolved path" {
	mkdir -p "$TMPDIR/mydir"
	ln -sf "$TMPDIR/mydir" "$(cdpath_dir)/mydir"
	run "$BM"
	[ "$status" -eq 0 ]
	[[ "$output" == *"mydir"* ]]
	[[ "$output" == *"$TMPDIR/mydir"* ]]
}

@test "list: dangling symlink shows resolved target path" {
	ln -sf "$TMPDIR/gone" "$(cdpath_dir)/ghost"
	run "$BM"
	[ "$status" -eq 0 ]
	[[ "$output" == *"ghost"* ]]
	[[ "$output" == *"$TMPDIR/gone"* ]]
}

# set

@test "set: creates symlink to PWD" {
	mkdir -p "$TMPDIR/proj"
	cd "$TMPDIR/proj"
	run "$BM" proj
	[ "$status" -eq 0 ]
	[ "$(bookmark_target proj)" = "$TMPDIR/proj" ]
}

@test "set: creates symlink to explicit path" {
	mkdir -p "$TMPDIR/proj"
	run "$BM" proj "$TMPDIR/proj"
	[ "$status" -eq 0 ]
	[ "$(bookmark_target proj)" = "$TMPDIR/proj" ]
}

@test "set: overwrites existing bookmark" {
	mkdir -p "$TMPDIR/a" "$TMPDIR/b"
	run "$BM" x "$TMPDIR/a"
	run "$BM" x "$TMPDIR/b"
	[ "$status" -eq 0 ]
	[ "$(bookmark_target x)" = "$TMPDIR/b" ]
}

@test "set: explicit path must exist" {
	run "$BM" x "$TMPDIR/nonexistent"
	[ "$status" -eq 64 ]
	[[ "$output" == *"E64"* ]]
}

@test "set: explicit path must be a directory" {
	touch "$TMPDIR/file"
	run "$BM" x "$TMPDIR/file"
	[ "$status" -eq 64 ]
	[[ "$output" == *"E64"* ]]
}

# name validation

@test "set: rejects name containing /" {
	run "$BM" foo/bar
	[ "$status" -eq 64 ]
	[[ "$output" == *"E64"* ]]
}

@test "set: rejects name starting with -" {
	run "$BM" -bad
	[ "$status" -eq 64 ]
	[[ "$output" == *"E64"* ]]
}

# delete

@test "delete: removes existing bookmark" {
	mkdir -p "$TMPDIR/proj"
	ln -sf "$TMPDIR/proj" "$(cdpath_dir)/proj"
	run "$BM" -d proj
	[ "$status" -eq 0 ]
	[ ! -e "$(cdpath_dir)/proj" ]
}

@test "delete: no-op on nonexistent bookmark" {
	run "$BM" -d nothing
	[ "$status" -eq 0 ]
}

# argument validation

@test "too many args exits with usage" {
	run "$BM" a b c
	[ "$status" -eq 1 ]
}
