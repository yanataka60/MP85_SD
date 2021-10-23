# MITEC MP-85にSD-Cardとのロード、セーブ機能

MP-85にSD-CARDを繋いだARDUINO(SD_ACCESS)とのシリアル同期通信によりロード、セーブを提供するルーチンです。


## 必要なもの
　2716×2個(Monitor-ROM置き換え用とSD-Cardアクセスルーチンを格納する拡張ROM用)
 
　ピンヘッダ等
 
## 注意点
　Monitor-ROM内のカセットとのロード、セーブルーチンとSD-Cardアクセスルーチンを入れ替えてしまえばROMは1個で済むと思われますが、Monitor-ROMの全容を把握していないため、現在は別ROMとしています。
 
　Monitor-ROMのカセットとのロード、セーブルーチンへジャンプするジャンプテーブルを書き換えることでカセットへのロード、セーブの操作方法そのままにSD-Cardへのロード、セーブが可能となります。
 
## 接続方法
　MP-85の解説書を所有していないため、CN2コネクタ信号については基板パターンを追った結果で作成しています。基板のRev等で違いがあった場合はご容赦ください。
 
　私の入手した基板ではCN2に+5Vが出ていませんでしたが、CN2-Jがフリーだったため、+5Vをジャンパしています。
 
Arduino　　　　　　　　　　MP-85

　　5V　　　　　　　-----　　5V　CN2-J
   
　　GND　　　　　　-----　　GND　CN2-I
   
　　9(FLG:output)　　　-----　　PB2(CHK:input)　CN2-7
             
　　8(OUT:output)　　-----　　PB0(IN:input)　CN2-4
                
　　7(CHK:input)　　　-----　　PA2(FLG:output)　CN2-11
                
　　6(IN :input)　　　　-----　　PA0(OUT:output)　CN2-12

## ROM
　file_trans_MP85.binを2716に焼いてIC27に装着します。

　IC25のMonitor-romの内容をコピーし、0168H～016BHのデータを修正した後、IC25に装着することでカセットへのロード、セーブの操作方法そのままにSD-Cardへのロード、セーブが可能となります。

　　0168 7F　->　00

　　0169 04　->　10

　　016A 73　->　03

　　016B 04　->　10

　Monitor-ROMにRev表記は無いので大丈夫だとは思いますが、修正前の内容が違っていた場合にはrev違いと思われますのでMonitor-ROMの差し替えはお控えください。

## 操作方法
### Load(Monitor-ROMを修正した場合)
　　FUNCキーを押した後にLOADキーを押します。

　　次にファイルNoを入力します。カセットインタフェースの場合には2桁ですが、4桁を入力してWRITEINCRキーを押してください。表示は下2桁しか表示されませんが、ちゃんと4桁分保存されています。

　　最後にWRITEINCRキーを押せばLoadが開始され、正常に終了されればEndと表示されます。

　　この時、Load先頭アドレスを実行開始アドレスとしてセットしてありますので良ければそのままRUNキーを押すことでプログラムの実行が可能です。

　　Errorと表示された場合は、SD-Cardが挿入されていない、ファイルNoのファイルが存在しない、読み込み中に何らかのエラーが発生した場合ですので確認してください。

### Load(Monitor-ROMを修正していない場合)
 ファイルNoを7F34Hにセット(例:ファイルNo　8000:73F4/ADRSSET/00/WRITEINCR/80/WRITEINCR)、
 
 実行アドレスをセット(7F1E/ADRSSET/00/WRITEINCR/10/WRITEINCR)して、RUNキーを押します。
 
### Save(Monitor-ROMを修正した場合)
　　FUNCキーを押した後にSAVEキーを押します。

　　ファイルNoを入力します。カセットインタフェースの場合には2桁ですが、4桁を入力してWRITEINCRキーを押してください。表示は下2桁しか表示されませんが、ちゃんと4桁分保存されています。

　　ファイルの上書きは禁止しています。SD-Cardに存在しないファイルNoを入力してください。

　　次にSAVE開始アドレスを入力してWRITEINCRキーを押し、SAVE終了アドレスを入力してWRITEINCRキーを押します。

　　最後にWRITEINCRキーを押せばSaveが開始され、正常に終了されればEndと表示されます。

　　Errorと表示された場合は、SD-Cardが挿入されていない、ファイルNoのファイルが既に存在する(上書き不可です)、書き込み中に何らかのエラーが発生した場合ですので確認してください。

### Save(Monitor-ROMを修正していない場合)
 ファイルNoを7F34Hにセット(例:ファイルNo　8000:73F4/ADRSSET/00/WRITEINCR/80/WRITEINCR)、
 
 Save開始アドレスをセット(例:開始アドレス　7C80:7336/ADRSSET/80/WRITEINCR/7C/WRITEINCR)、
 
 Save終了アドレスをセット(例:終了アドレス　7CFF:734D/ADRSSET/FF/WRITEINCR/7C/WRITEINCR)、
 
 実行アドレスをセット(7F1E/ADRSSET/03/WRITEINCR/10/WRITEINCR)して、RUNキーを押す。

## 今後
　Monior-ROMの逆アセンブルリストからカセットI/Oルーチンの範囲が特定できればSD-Cardルーチンと置き換え、拡張ROMを必要としないようにしたいと考えています。
