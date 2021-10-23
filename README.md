# MITEC MP-85にSD-Cardとのロード、セーブ機能

MP-85にSD-CARDを繋いだARDUINO(SD_ACCESS)とのシリアル同期通信によりロード、セーブを提供するルーチンです。


## 必要なもの
　2716×2個(Monitor-ROM置き換え用とSD-Cardアクセスルーチンを格納する拡張ROM用)
 
　ピンヘッダ等
 
## 注意点
　Monitor-ROM内のカセットとのロード、セーブルーチンとSD-Cardアクセスルーチンを入れ替えてしまえばROMは1個で済むと思われますが、Monitor-ROMの全容を把握していないため、現在は別ROMとしています。
 
　Monitor-ROMのカセットとのロード、セーブルーチンへジャンプするジャンプテーブルを書き換えることでカセットへのロード、セーブの操作方法そのままにSD-Cardとのロード、セーブが可能となります。
 
##接続方法
　MP-85の解説書を所有していないため、CN2コネクタ信号については基板パターンを追った結果で作成しています。基板のRev等で違いがあった場合はご容赦ください。
 
　私の入手した基板ではCN2に+5Vが出ていませんでしたが、CN2-Jがフリーだったため、+5Vをジャンパしています。
 
Arduino　　　　　　　　　　MP-85
　　5V　　　　　　　-----　　5V　CN2-J
   
　　GND　　　　　　-----　　GND　CN2-I
   
　　9(FLG:output)　　　-----　　PB2(CHK:input)　CN2-7
             
　　8(OUT:output)　　-----　　PB0(IN:input)　CN2-4
                
　　7(CHK:input)　　　-----　　PA2(FLG:output)　CN2-11
                
　　6(IN :input)　　　　-----　　PA0(OUT:output)　CN2-12
