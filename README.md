# Rails5のためのDockerfile

以下の内容をインストールし、Railsアプリケーションを実行する。
Railsアプリケーションはコンテナ作成時に、内部で作成する。

* CentOS7
* Rails5
* Apatch
* passenger

## Usage

```bash
$ docker pull dynamonda/rails_i:<version>
$ docker run -d -p 3000:3000 dynamonda/rails_i
```

ポートは3000番を使用している。

## Version

* v1.2:passenger start rails app
* v1.0:rails server start

