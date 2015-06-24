# AnotherDatabaseプラグイン

## はじめに

このプラグインは、MovableType上でテキストスニペットを管理するための仕組みと、テンプレート上でテキストスニペットを呼び出すタグを提供します。

## インストール

本パッケージに含まれる「**plugins**」ディレクトリ内のディレクトリ「Multilabel」を、Movable
Typeインストールディレクトリの「**plugins**」ディレクトリの下にコピーしてください。\
作業後、Movable Typeのシステム・メニューのプラグイン管理画面を表示し、プラグインの一覧に「Multilabel」が表示されていることを確認してください。

## 使い方

### 設定

システム、ウェブサイト、ブログのプラグインから設定することができます。

分類(class)はカンマ(,)区切りで入力すると、キーワードと対になるテキストフィールドが追加されます。
デフォルトでは、ja, en, cn, krが登録されています。


#### 例

### MTタグ

#### Multilabel (ブロックタグ)

ラベルのクラスをグローバルに定義します。
このブロックタグ内では後述するMultilabelTextタグ(ファンクションタグ)のclassを省略することができます。

##### モディファイヤ

- class
    - 各ラベルに定義されているクラスを指定します。


#### MultilabelText (ファンクションタグ)

##### モディファイヤ

- keyword
    - ラベルのキーワードを指定します。
- class
    - 各ラベルに定義されているクラスを指定します。
    - Multilabelタグでの指定よりも、こちらが優先されます。


## 例

### ブロックタグを使用してclassを指定し、その中でファンクションタグで呼び出す。

```
<mt:Multilabel class="ja">
    <mt:MultilabelText keyword="about">
    <mt:MultilabelText keyword="about" class="en">
</mt:Multilabel>

<!-- 出力 -->
概要
About

```

## 注記
