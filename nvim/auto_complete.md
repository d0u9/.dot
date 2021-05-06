# Auto Complete Note

## Golang

```
GO111MODULE=on go get golang.org/x/tools/gopls@latest
```

## Rust

```
curl -L https://github.com/rust-analyzer/rust-analyzer/releases/latest/download/rust-analyzer-linux -o ~/Apps/bin/rust-analyzer
chmod +x ~/Apps/bin/rust-analyzer
```

## C & C++

```
git clone --depth=1 --recursive https://github.com/MaskRay/ccls
cd ccls
```

Download and install clang+llvm

```
https://github.com/llvm/llvm-project/releases/download/llvmorg-12.0.0/clang+llvm-12.0.0-x86_64-linux-gnu-ubuntu-20.04.tar.xz
tar ...
mv ... ~/Apps/cellar/clang_llvm

sudo apt-get install libclang-10-dev
```

Build ccls

```
cmake -H. -BRelease -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=/home/doug/cellar/clang_llvm
cmake --build Release
cp Release/ccls ~/Apps/bin
```

