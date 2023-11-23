clear;clc; % すべての変数をクリアし、コマンドウィンドウをクリアする

[file,path] = uigetfile('*.wav'); % ユーザーにwavファイルを選択させる
if isequal(file,0)
    disp('User selected Cancel'); % ユーザーがキャンセルした場合のメッセージ
else
    disp(['User selected ', fullfile(path,file)]); % 選択されたファイルのパスを表示
end

fs = 44.1e3; % サンプリング周波数を44.1kHzに設定
samples = [1,5*fs-1]; % 5秒間のサンプルを設定
clear pn fs;
[pn,fs] = audioread(file,samples); % 指定されたサンプル範囲でオーディオファイルを読み込む

flims = [20 20e3]; % 周波数の範囲を20Hzから20kHzに設定
bpo = 3; % オクターブごとのバンド数を3に設定
opts = {'FrequencyLimits',flims,'BandsPerOctave',bpo}; % オプションを設定

disp(pn(1)) % 最初のサンプル値を表示
disp(pn(5*fs-1)) % 最後のサンプル値を表示

poctave(pn,fs,opts{:}); % 周波数分析を行い、プロットする
savefig('BandsPerOctave.fig'); % 図を保存
close all % すべての図を閉じる

fig = open('BandsPerOctave.fig'); % 保存した図を開く
ax = fig.Children; % 図の軸を取得
x = ax.Children.XData; % X軸のデータを取得
y = ax.Children.YData; % Y軸のデータを取得

disp(x) % X軸のデータを表示
disp(y) % Y軸のデータを表示

xHz = [20 25 31.5 40 50 63 80 100 125 160 200 250 315 400 500 630 800 1000 1250 1600 2000 2500 3150 4000 5000 6300 8000 10000 12500 16000 20000];

[pks,locs] = findpeaks(y); % Y軸データからピークを検出
plot(y); % プロット
hold on;
plot(locs,y(locs),'ro'); % ピークを赤い丸で表示
hold off;
savefig('peaks.fig'); % ピークの図を保存
close all % すべての図を閉じる

maxpks = maxk(pks,3); % 最大の3つのピークを見つける
for index = 1:numel(locs)
    if pks(index)==maxpks(1)
        a = index;
    elseif pks(index)==maxpks(2)
        b = index;
    elseif pks(index)==maxpks(3)
        c = index;
    end
end

nbins = 15; % ヒストグラムのビンの数を15に設定
histogram(y,nbins); % ヒストグラムを描画
savefig('histogram.fig'); % ヒストグラムの図を保存
close all % すべての図を閉じる

[N,edges] = histcounts(y,nbins); % ヒストグラムのカウントを取得
[NM,NI] = max(N); % 最も多いビンを見つける
for index = 1:NI + 1
    disp("data")
    disp(index)
    disp(edges(index))
end
modeN = (edges(NI)+edges(NI+1))/2; % 最頻値を計算

No = [1;2;3];
Hz = {xHz(locs(a));xHz(locs(b));xHz(locs(c))}; % ピークの周波数を取得
dB = [-(pks(a)-modeN);-(pks(b)-modeN);-(pks(c)-modeN)]; % ピークのデシベル値を計算
mode_dB = [modeN;0;0]; % 最頻値のデシベル値を計算
T = table(No,Hz,dB,mode_dB) % テーブルを作成
writetable(T,'result_data.txt'); % テーブルをテキストファイルに保存
type result_data.txt % テキストファイルの内容を表示
