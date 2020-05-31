package Date::Holidays::TW;
use strict;
use utf8;

our $VERSION = v0.1.1;

use Exporter 'import';
our @EXPORT_OK = qw(is_tw_holiday tw_holidays);

use DateTime;
use DateTime::Calendar::Chinese;

my %NATIONAL = (
    '0101' => '中華民國開國紀念日',
    '0228' => '和平紀念日',
    '0404' => '兒童節',
    '1010' => '國慶日',
);

my %FOLK_LUNAR = (
    '0101' => '春節',
    '0102' => '春節',
    '0103' => '春節',
    '0505' => '端午節',
    '0815' => '中秋節',
    '1230' => '農曆除夕',
    # '????' => '清明節' (民族掃墓節)
);

# Below is the output of:
#
#     perl ./dev-bin/convert-from-csv.pl 308DCD75-6434-45BC-A95F-584DA4FED251-政府行政機關辦公日曆表_6929026892684952322.csv
#
# Where that CSV is downloadable from: https://data.gov.tw/dataset/123662

my %CAL = (
    2013 => {
        "0101" => "中華民國開國紀念日",
        "0105" => "星期六、星期日",
        "0106" => "星期六、星期日",
        "0112" => "星期六、星期日",
        "0113" => "星期六、星期日",
        "0119" => "星期六、星期日",
        "0120" => "星期六、星期日",
        "0126" => "星期六、星期日",
        "0127" => "星期六、星期日",
        "0202" => "星期六、星期日",
        "0203" => "星期六、星期日",
        "0209" => "農曆除夕",
        "0210" => "春節",
        "0211" => "春節",
        "0212" => "春節",
        "0213" => "補假",
        "0214" => "補假",
        "0215" => "調整放假日",
        "0216" => "星期六、星期日",
        "0217" => "星期六、星期日",
        "0223" => "",
        "0224" => "星期日",
        "0228" => "和平紀念日",
        "0302" => "星期六、星期日",
        "0303" => "星期六、星期日",
        "0308" => "",
        "0309" => "星期六、星期日",
        "0310" => "星期六、星期日",
        "0316" => "星期六、星期日",
        "0317" => "星期六、星期日",
        "0323" => "星期六、星期日",
        "0324" => "星期六、星期日",
        "0329" => "",
        "0330" => "星期六、星期日",
        "0331" => "星期六、星期日",
        "0404" => "清明節、兒童節",
        "0405" => "調整放假日",
        "0406" => "星期六、星期日",
        "0407" => "星期六、星期日",
        "0413" => "星期六、星期日",
        "0414" => "星期六、星期日",
        "0420" => "星期六、星期日",
        "0421" => "星期六、星期日",
        "0427" => "星期六、星期日",
        "0428" => "星期六、星期日",
        "0501" => "勞動節",
        "0504" => "星期六、星期日",
        "0505" => "星期六、星期日",
        "0511" => "星期六、星期日",
        "0512" => "星期六、星期日",
        "0518" => "星期六、星期日",
        "0519" => "星期六、星期日",
        "0525" => "星期六、星期日",
        "0526" => "星期六、星期日",
        "0601" => "星期六、星期日",
        "0602" => "星期六、星期日",
        "0608" => "星期六、星期日",
        "0609" => "星期六、星期日",
        "0612" => "端午節",
        "0615" => "星期六、星期日",
        "0616" => "星期六、星期日",
        "0622" => "星期六、星期日",
        "0623" => "星期六、星期日",
        "0629" => "星期六、星期日",
        "0630" => "星期六、星期日",
        "0706" => "星期六、星期日",
        "0707" => "星期六、星期日",
        "0713" => "星期六、星期日",
        "0714" => "星期六、星期日",
        "0720" => "星期六、星期日",
        "0721" => "星期六、星期日",
        "0727" => "星期六、星期日",
        "0728" => "星期六、星期日",
        "0803" => "星期六、星期日",
        "0804" => "星期六、星期日",
        "0810" => "星期六、星期日",
        "0811" => "星期六、星期日",
        "0817" => "星期六、星期日",
        "0818" => "星期六、星期日",
        "0824" => "星期六、星期日",
        "0825" => "星期六、星期日",
        "0831" => "星期六、星期日",
        "0901" => "星期六、星期日",
        "0903" => "",
        "0907" => "星期六、星期日",
        "0908" => "星期六、星期日",
        "0914" => "",
        "0915" => "星期日",
        "0919" => "中秋節",
        "0920" => "調整放假日",
        "0921" => "星期六、星期日",
        "0922" => "星期六、星期日",
        "0928" => "教師節",
        "0929" => "星期六、星期日",
        "1005" => "星期六、星期日",
        "1006" => "星期六、星期日",
        "1010" => "國慶日",
        "1012" => "星期六、星期日",
        "1013" => "星期六、星期日",
        "1019" => "星期六、星期日",
        "1020" => "星期六、星期日",
        "1025" => "",
        "1026" => "星期六、星期日",
        "1027" => "星期六、星期日",
        "1102" => "星期六、星期日",
        "1103" => "星期六、星期日",
        "1109" => "星期六、星期日",
        "1110" => "星期六、星期日",
        "1112" => "",
        "1116" => "星期六、星期日",
        "1117" => "星期六、星期日",
        "1123" => "星期六、星期日",
        "1124" => "星期六、星期日",
        "1130" => "星期六、星期日",
        "1201" => "星期六、星期日",
        "1207" => "星期六、星期日",
        "1208" => "星期六、星期日",
        "1214" => "星期六、星期日",
        "1215" => "星期六、星期日",
        "1221" => "星期六、星期日",
        "1222" => "星期六、星期日",
        "1225" => "",
        "1228" => "星期六、星期日",
        "1229" => "星期六、星期日",
    },
    2014 => {
        "0101" => "中華民國開國紀念日",
        "0104" => "星期六、星期日",
        "0105" => "星期六、星期日",
        "0111" => "星期六、星期日",
        "0112" => "星期六、星期日",
        "0118" => "星期六、星期日",
        "0119" => "星期六、星期日",
        "0125" => "星期六、星期日",
        "0126" => "星期六、星期日",
        "0130" => "農曆除夕",
        "0131" => "春節",
        "0201" => "春節",
        "0202" => "春節",
        "0203" => "補假",
        "0204" => "補假",
        "0208" => "星期六、星期日",
        "0209" => "星期六、星期日",
        "0215" => "星期六、星期日",
        "0216" => "星期六、星期日",
        "0222" => "星期六、星期日",
        "0223" => "星期六、星期日",
        "0228" => "和平紀念日",
        "0301" => "星期六、星期日",
        "0302" => "星期六、星期日",
        "0308" => "婦女節",
        "0309" => "星期六、星期日",
        "0315" => "星期六、星期日",
        "0316" => "星期六、星期日",
        "0322" => "星期六、星期日",
        "0323" => "星期六、星期日",
        "0329" => "青年節",
        "0330" => "星期六、星期日",
        "0404" => "兒童節",
        "0405" => "民族掃墓節",
        "0406" => "星期六、星期日",
        "0412" => "星期六、星期日",
        "0413" => "星期六、星期日",
        "0419" => "星期六、星期日",
        "0420" => "星期六、星期日",
        "0426" => "星期六、星期日",
        "0427" => "星期六、星期日",
        "0501" => "勞動節",
        "0503" => "星期六、星期日",
        "0504" => "星期六、星期日",
        "0510" => "星期六、星期日",
        "0511" => "星期六、星期日",
        "0517" => "星期六、星期日",
        "0518" => "星期六、星期日",
        "0524" => "星期六、星期日",
        "0525" => "星期六、星期日",
        "0531" => "星期六、星期日",
        "0601" => "星期六、星期日",
        "0602" => "端午節",
        "0607" => "星期六、星期日",
        "0608" => "星期六、星期日",
        "0614" => "星期六、星期日",
        "0615" => "星期六、星期日",
        "0621" => "星期六、星期日",
        "0622" => "星期六、星期日",
        "0628" => "星期六、星期日",
        "0629" => "星期六、星期日",
        "0705" => "星期六、星期日",
        "0706" => "星期六、星期日",
        "0712" => "星期六、星期日",
        "0713" => "星期六、星期日",
        "0719" => "星期六、星期日",
        "0720" => "星期六、星期日",
        "0726" => "星期六、星期日",
        "0727" => "星期六、星期日",
        "0802" => "星期六、星期日",
        "0803" => "星期六、星期日",
        "0809" => "星期六、星期日",
        "0810" => "星期六、星期日",
        "0816" => "星期六、星期日",
        "0817" => "星期六、星期日",
        "0823" => "星期六、星期日",
        "0824" => "星期六、星期日",
        "0830" => "星期六、星期日",
        "0831" => "星期六、星期日",
        "0903" => "",
        "0906" => "星期六、星期日",
        "0907" => "星期六、星期日",
        "0908" => "中秋節",
        "0913" => "星期六、星期日",
        "0914" => "星期六、星期日",
        "0920" => "星期六、星期日",
        "0921" => "星期六、星期日",
        "0927" => "星期六、星期日",
        "0928" => "教師節",
        "1004" => "星期六、星期日",
        "1005" => "星期六、星期日",
        "1010" => "國慶日",
        "1011" => "星期六、星期日",
        "1012" => "星期六、星期日",
        "1018" => "星期六、星期日",
        "1019" => "星期六、星期日",
        "1025" => "臺灣光復節",
        "1026" => "星期六、星期日",
        "1101" => "星期六、星期日",
        "1102" => "星期六、星期日",
        "1108" => "星期六、星期日",
        "1109" => "星期六、星期日",
        "1112" => "",
        "1115" => "星期六、星期日",
        "1116" => "星期六、星期日",
        "1122" => "星期六、星期日",
        "1123" => "星期六、星期日",
        "1129" => "星期六、星期日",
        "1130" => "星期六、星期日",
        "1206" => "星期六、星期日",
        "1207" => "星期六、星期日",
        "1213" => "星期六、星期日",
        "1214" => "星期六、星期日",
        "1220" => "星期六、星期日",
        "1221" => "星期六、星期日",
        "1225" => "",
        "1227" => "",
        "1228" => "星期六、星期日",
    },
    2015 => {
        "0101" => "中華民國開國紀念日",
        "0102" => "調整放假日",
        "0103" => "星期六、星期日",
        "0104" => "星期六、星期日",
        "0110" => "星期六、星期日",
        "0111" => "星期六、星期日",
        "0117" => "星期六、星期日",
        "0118" => "星期六、星期日",
        "0124" => "星期六、星期日",
        "0125" => "星期六、星期日",
        "0131" => "星期六、星期日",
        "0201" => "星期六、星期日",
        "0207" => "星期六、星期日",
        "0208" => "星期六、星期日",
        "0214" => "星期六、星期日",
        "0215" => "星期六、星期日",
        "0218" => "農曆除夕",
        "0219" => "春節",
        "0220" => "春節",
        "0221" => "春節",
        "0222" => "星期六、星期日",
        "0223" => "補假",
        "0227" => "補假",
        "0228" => "和平紀念日",
        "0301" => "星期六、星期日",
        "0307" => "星期六、星期日",
        "0308" => "星期六、星期日",
        "0314" => "星期六、星期日",
        "0315" => "星期六、星期日",
        "0321" => "星期六、星期日",
        "0322" => "星期六、星期日",
        "0328" => "星期六、星期日",
        "0329" => "星期六、星期日",
        "0403" => "補假",
        "0404" => "兒童節",
        "0405" => "民族掃墓節（清明節）",
        "0406" => "補假",
        "0411" => "星期六、星期日",
        "0412" => "星期六、星期日",
        "0418" => "星期六、星期日",
        "0419" => "星期六、星期日",
        "0425" => "星期六、星期日",
        "0426" => "星期六、星期日",
        "0501" => "勞動節",
        "0502" => "星期六、星期日",
        "0503" => "星期六、星期日",
        "0509" => "星期六、星期日",
        "0510" => "星期六、星期日",
        "0516" => "星期六、星期日",
        "0517" => "星期六、星期日",
        "0523" => "星期六、星期日",
        "0524" => "星期六、星期日",
        "0530" => "星期六、星期日",
        "0531" => "星期六、星期日",
        "0606" => "星期六、星期日",
        "0607" => "星期六、星期日",
        "0613" => "星期六、星期日",
        "0614" => "星期六、星期日",
        "0619" => "補假",
        "0620" => "端午節",
        "0621" => "星期六、星期日",
        "0627" => "星期六、星期日",
        "0628" => "星期六、星期日",
        "0704" => "星期六、星期日",
        "0705" => "星期六、星期日",
        "0711" => "星期六、星期日",
        "0712" => "星期六、星期日",
        "0718" => "星期六、星期日",
        "0719" => "星期六、星期日",
        "0725" => "星期六、星期日",
        "0726" => "星期六、星期日",
        "0801" => "星期六、星期日",
        "0802" => "星期六、星期日",
        "0808" => "星期六、星期日",
        "0809" => "星期六、星期日",
        "0815" => "星期六、星期日",
        "0816" => "星期六、星期日",
        "0822" => "星期六、星期日",
        "0823" => "星期六、星期日",
        "0829" => "星期六、星期日",
        "0830" => "星期六、星期日",
        "0903" => "軍人節",
        "0905" => "星期六、星期日",
        "0906" => "星期六、星期日",
        "0912" => "星期六、星期日",
        "0913" => "星期六、星期日",
        "0919" => "星期六、星期日",
        "0920" => "星期六、星期日",
        "0926" => "星期六、星期日",
        "0927" => "中秋節",
        "0928" => "補假",
        "1003" => "星期六、星期日",
        "1004" => "星期六、星期日",
        "1009" => "補假",
        "1010" => "國慶日",
        "1011" => "星期六、星期日",
        "1017" => "星期六、星期日",
        "1018" => "星期六、星期日",
        "1024" => "星期六、星期日",
        "1025" => "星期六、星期日",
        "1031" => "星期六、星期日",
        "1101" => "星期六、星期日",
        "1107" => "星期六、星期日",
        "1108" => "星期六、星期日",
        "1114" => "星期六、星期日",
        "1115" => "星期六、星期日",
        "1121" => "星期六、星期日",
        "1122" => "星期六、星期日",
        "1128" => "星期六、星期日",
        "1129" => "星期六、星期日",
        "1205" => "星期六、星期日",
        "1206" => "星期六、星期日",
        "1212" => "星期六、星期日",
        "1213" => "星期六、星期日",
        "1219" => "星期六、星期日",
        "1220" => "星期六、星期日",
        "1226" => "星期六、星期日",
        "1227" => "星期六、星期日",
    },
    2016 => {
        "0101" => "中華民國開國紀念日",
        "0102" => "星期六、星期日",
        "0103" => "星期六、星期日",
        "0109" => "星期六、星期日",
        "0110" => "星期六、星期日",
        "0116" => "星期六、星期日",
        "0117" => "星期六、星期日",
        "0123" => "星期六、星期日",
        "0124" => "星期六、星期日",
        "0130" => "",
        "0131" => "星期六、星期日",
        "0206" => "星期六、星期日",
        "0207" => "農曆除夕",
        "0208" => "春節",
        "0209" => "春節",
        "0210" => "春節",
        "0211" => "補假",
        "0212" => "調整放假日",
        "0213" => "星期六、星期日",
        "0214" => "星期六、星期日",
        "0220" => "星期六、星期日",
        "0221" => "星期六、星期日",
        "0227" => "星期六、星期日",
        "0228" => "和平紀念日",
        "0229" => "補假",
        "0305" => "星期六、星期日",
        "0306" => "星期六、星期日",
        "0312" => "星期六、星期日",
        "0313" => "星期六、星期日",
        "0319" => "星期六、星期日",
        "0320" => "星期六、星期日",
        "0326" => "星期六、星期日",
        "0327" => "星期六、星期日",
        "0402" => "星期六、星期日",
        "0403" => "放假之紀念日及節日",
        "0404" => "兒童節、民族掃墓節（清明節）",
        "0405" => "補假",
        "0409" => "星期六、星期日",
        "0410" => "星期六、星期日",
        "0416" => "星期六、星期日",
        "0417" => "星期六、星期日",
        "0423" => "星期六、星期日",
        "0424" => "星期六、星期日",
        "0430" => "星期六、星期日",
        "0501" => "勞動節",
        "0507" => "星期六、星期日",
        "0508" => "星期六、星期日",
        "0514" => "星期六、星期日",
        "0515" => "星期六、星期日",
        "0521" => "星期六、星期日",
        "0522" => "星期六、星期日",
        "0528" => "星期六、星期日",
        "0529" => "星期六、星期日",
        "0604" => "",
        "0605" => "星期六、星期日",
        "0609" => "端午節",
        "0610" => "調整放假日",
        "0611" => "星期六、星期日",
        "0612" => "星期六、星期日",
        "0618" => "星期六、星期日",
        "0619" => "星期六、星期日",
        "0625" => "星期六、星期日",
        "0626" => "星期六、星期日",
        "0702" => "星期六、星期日",
        "0703" => "星期六、星期日",
        "0709" => "星期六、星期日",
        "0710" => "星期六、星期日",
        "0716" => "星期六、星期日",
        "0717" => "星期六、星期日",
        "0723" => "星期六、星期日",
        "0724" => "星期六、星期日",
        "0730" => "星期六、星期日",
        "0731" => "星期六、星期日",
        "0806" => "星期六、星期日",
        "0807" => "星期六、星期日",
        "0813" => "星期六、星期日",
        "0814" => "星期六、星期日",
        "0820" => "星期六、星期日",
        "0821" => "星期六、星期日",
        "0827" => "星期六、星期日",
        "0828" => "星期六、星期日",
        "0903" => "軍人節",
        "0904" => "星期六、星期日",
        "0910" => "",
        "0911" => "星期六、星期日",
        "0915" => "中秋節",
        "0916" => "調整放假日",
        "0917" => "星期六、星期日",
        "0918" => "星期六、星期日",
        "0924" => "星期六、星期日",
        "0925" => "星期六、星期日",
        "1001" => "星期六、星期日",
        "1002" => "星期六、星期日",
        "1008" => "星期六、星期日",
        "1009" => "星期六、星期日",
        "1010" => "國慶日",
        "1015" => "星期六、星期日",
        "1016" => "星期六、星期日",
        "1022" => "星期六、星期日",
        "1023" => "星期六、星期日",
        "1029" => "星期六、星期日",
        "1030" => "星期六、星期日",
        "1105" => "星期六、星期日",
        "1106" => "星期六、星期日",
        "1112" => "星期六、星期日",
        "1113" => "星期六、星期日",
        "1119" => "星期六、星期日",
        "1120" => "星期六、星期日",
        "1126" => "星期六、星期日",
        "1127" => "星期六、星期日",
        "1203" => "星期六、星期日",
        "1204" => "星期六、星期日",
        "1210" => "星期六、星期日",
        "1211" => "星期六、星期日",
        "1217" => "星期六、星期日",
        "1218" => "星期六、星期日",
        "1224" => "星期六、星期日",
        "1225" => "星期六、星期日",
        "1231" => "星期六、星期日",
    },
    2017 => {
        "0101" => "中華民國開國紀念日",
        "0102" => "補假",
        "0107" => "星期六、星期日",
        "0108" => "星期六、星期日",
        "0114" => "星期六、星期日",
        "0115" => "星期六、星期日",
        "0121" => "星期六、星期日",
        "0122" => "星期六、星期日",
        "0127" => "農曆除夕",
        "0128" => "春節",
        "0129" => "春節",
        "0130" => "春節",
        "0131" => "補假",
        "0201" => "補假",
        "0204" => "星期六、星期日",
        "0205" => "星期六、星期日",
        "0211" => "星期六、星期日",
        "0212" => "星期六、星期日",
        "0218" => "",
        "0219" => "星期六、星期日",
        "0225" => "星期六、星期日",
        "0226" => "星期六、星期日",
        "0227" => "調整放假日",
        "0228" => "和平紀念日",
        "0304" => "星期六、星期日",
        "0305" => "星期六、星期日",
        "0311" => "星期六、星期日",
        "0312" => "星期六、星期日",
        "0318" => "星期六、星期日",
        "0319" => "星期六、星期日",
        "0325" => "星期六、星期日",
        "0326" => "星期六、星期日",
        "0401" => "星期六、星期日",
        "0402" => "星期六、星期日",
        "0403" => "放假之紀念日及節日",
        "0404" => "兒童節、民族掃墓節（清明節）",
        "0408" => "星期六、星期日",
        "0409" => "星期六、星期日",
        "0415" => "星期六、星期日",
        "0416" => "星期六、星期日",
        "0422" => "星期六、星期日",
        "0423" => "星期六、星期日",
        "0429" => "星期六、星期日",
        "0430" => "星期六、星期日",
        "0501" => "勞動節",
        "0506" => "星期六、星期日",
        "0507" => "星期六、星期日",
        "0513" => "星期六、星期日",
        "0514" => "星期六、星期日",
        "0520" => "星期六、星期日",
        "0521" => "星期六、星期日",
        "0527" => "星期六、星期日",
        "0528" => "星期六、星期日",
        "0529" => "調整放假日",
        "0530" => "端午節",
        "0603" => "",
        "0604" => "星期六、星期日",
        "0610" => "星期六、星期日",
        "0611" => "星期六、星期日",
        "0617" => "星期六、星期日",
        "0618" => "星期六、星期日",
        "0624" => "星期六、星期日",
        "0625" => "星期六、星期日",
        "0701" => "星期六、星期日",
        "0702" => "星期六、星期日",
        "0708" => "星期六、星期日",
        "0709" => "星期六、星期日",
        "0715" => "星期六、星期日",
        "0716" => "星期六、星期日",
        "0722" => "星期六、星期日",
        "0723" => "星期六、星期日",
        "0729" => "星期六、星期日",
        "0730" => "星期六、星期日",
        "0805" => "星期六、星期日",
        "0806" => "星期六、星期日",
        "0812" => "星期六、星期日",
        "0813" => "星期六、星期日",
        "0819" => "星期六、星期日",
        "0820" => "星期六、星期日",
        "0826" => "星期六、星期日",
        "0827" => "星期六、星期日",
        "0902" => "星期六、星期日",
        "0903" => "軍人節",
        "0909" => "星期六、星期日",
        "0910" => "星期六、星期日",
        "0916" => "星期六、星期日",
        "0917" => "星期六、星期日",
        "0923" => "星期六、星期日",
        "0924" => "星期六、星期日",
        "0930" => "",
        "1001" => "星期六、星期日",
        "1004" => "中秋節",
        "1007" => "星期六、星期日",
        "1008" => "星期六、星期日",
        "1009" => "調整放假日",
        "1010" => "國慶日",
        "1014" => "星期六、星期日",
        "1015" => "星期六、星期日",
        "1021" => "星期六、星期日",
        "1022" => "星期六、星期日",
        "1028" => "星期六、星期日",
        "1029" => "星期六、星期日",
        "1104" => "星期六、星期日",
        "1105" => "星期六、星期日",
        "1111" => "星期六、星期日",
        "1112" => "星期六、星期日",
        "1118" => "星期六、星期日",
        "1119" => "星期六、星期日",
        "1125" => "星期六、星期日",
        "1126" => "星期六、星期日",
        "1202" => "星期六、星期日",
        "1203" => "星期六、星期日",
        "1209" => "星期六、星期日",
        "1210" => "星期六、星期日",
        "1216" => "星期六、星期日",
        "1217" => "星期六、星期日",
        "1223" => "星期六、星期日",
        "1224" => "星期六、星期日",
        "1230" => "星期六、星期日",
        "1231" => "星期六、星期日",
    },
    2018 => {
        "0101" => "中華民國開國紀念日",
        "0106" => "星期六、星期日",
        "0107" => "星期六、星期日",
        "0113" => "星期六、星期日",
        "0114" => "星期六、星期日",
        "0120" => "星期六、星期日",
        "0121" => "星期六、星期日",
        "0127" => "星期六、星期日",
        "0128" => "星期六、星期日",
        "0203" => "星期六、星期日",
        "0204" => "星期六、星期日",
        "0210" => "星期六、星期日",
        "0211" => "星期六、星期日",
        "0215" => "農曆除夕",
        "0216" => "春節",
        "0217" => "春節",
        "0218" => "春節",
        "0219" => "補假",
        "0220" => "補假",
        "0224" => "星期六、星期日",
        "0225" => "星期六、星期日",
        "0228" => "和平紀念日",
        "0303" => "星期六、星期日",
        "0304" => "星期六、星期日",
        "0310" => "星期六、星期日",
        "0311" => "星期六、星期日",
        "0317" => "星期六、星期日",
        "0318" => "星期六、星期日",
        "0324" => "星期六、星期日",
        "0325" => "星期六、星期日",
        "0331" => "",
        "0401" => "星期六、星期日",
        "0404" => "兒童節",
        "0405" => "民族掃墓節（清明節）",
        "0406" => "調整放假日",
        "0407" => "星期六、星期日",
        "0408" => "星期六、星期日",
        "0414" => "星期六、星期日",
        "0415" => "星期六、星期日",
        "0421" => "星期六、星期日",
        "0422" => "星期六、星期日",
        "0428" => "星期六、星期日",
        "0429" => "星期六、星期日",
        "0501" => "勞動節",
        "0505" => "星期六、星期日",
        "0506" => "星期六、星期日",
        "0512" => "星期六、星期日",
        "0513" => "星期六、星期日",
        "0519" => "星期六、星期日",
        "0520" => "星期六、星期日",
        "0526" => "星期六、星期日",
        "0527" => "星期六、星期日",
        "0602" => "星期六、星期日",
        "0603" => "星期六、星期日",
        "0609" => "星期六、星期日",
        "0610" => "星期六、星期日",
        "0616" => "星期六、星期日",
        "0617" => "星期六、星期日",
        "0618" => "端午節",
        "0623" => "星期六、星期日",
        "0624" => "星期六、星期日",
        "0630" => "星期六、星期日",
        "0701" => "星期六、星期日",
        "0707" => "星期六、星期日",
        "0708" => "星期六、星期日",
        "0714" => "星期六、星期日",
        "0715" => "星期六、星期日",
        "0721" => "星期六、星期日",
        "0722" => "星期六、星期日",
        "0728" => "星期六、星期日",
        "0729" => "星期六、星期日",
        "0804" => "星期六、星期日",
        "0805" => "星期六、星期日",
        "0811" => "星期六、星期日",
        "0812" => "星期六、星期日",
        "0818" => "星期六、星期日",
        "0819" => "星期六、星期日",
        "0825" => "星期六、星期日",
        "0826" => "星期六、星期日",
        "0901" => "星期六、星期日",
        "0902" => "星期六、星期日",
        "0903" => "軍人節",
        "0908" => "星期六、星期日",
        "0909" => "星期六、星期日",
        "0915" => "星期六、星期日",
        "0916" => "星期六、星期日",
        "0922" => "星期六、星期日",
        "0923" => "星期六、星期日",
        "0924" => "中秋節",
        "0929" => "星期六、星期日",
        "0930" => "星期六、星期日",
        "1006" => "星期六、星期日",
        "1007" => "星期六、星期日",
        "1010" => "國慶日",
        "1013" => "星期六、星期日",
        "1014" => "星期六、星期日",
        "1020" => "星期六、星期日",
        "1021" => "星期六、星期日",
        "1027" => "星期六、星期日",
        "1028" => "星期六、星期日",
        "1103" => "星期六、星期日",
        "1104" => "星期六、星期日",
        "1110" => "星期六、星期日",
        "1111" => "星期六、星期日",
        "1117" => "星期六、星期日",
        "1118" => "星期六、星期日",
        "1124" => "星期六、星期日",
        "1125" => "星期六、星期日",
        "1201" => "星期六、星期日",
        "1202" => "星期六、星期日",
        "1208" => "星期六、星期日",
        "1209" => "星期六、星期日",
        "1215" => "星期六、星期日",
        "1216" => "星期六、星期日",
        "1222" => "",
        "1223" => "星期六、星期日",
        "1229" => "星期六、星期日",
        "1230" => "星期六、星期日",
        "1231" => "調整放假日",
    },
    2019 => {
        "0101" => "中華民國開國紀念日",
        "0105" => "星期六、星期日",
        "0106" => "星期六、星期日",
        "0112" => "星期六、星期日",
        "0113" => "星期六、星期日",
        "0119" => "",
        "0120" => "星期六、星期日",
        "0126" => "星期六、星期日",
        "0127" => "星期六、星期日",
        "0202" => "星期六、星期日",
        "0203" => "星期六、星期日",
        "0204" => "農曆除夕",
        "0205" => "春節",
        "0206" => "春節",
        "0207" => "春節",
        "0208" => "調整放假日",
        "0209" => "星期六、星期日",
        "0210" => "星期六、星期日",
        "0216" => "星期六、星期日",
        "0217" => "星期六、星期日",
        "0223" => "",
        "0224" => "星期六、星期日",
        "0228" => "和平紀念日",
        "0301" => "調整放假日",
        "0302" => "星期六、星期日",
        "0303" => "星期六、星期日",
        "0309" => "星期六、星期日",
        "0310" => "星期六、星期日",
        "0316" => "星期六、星期日",
        "0317" => "星期六、星期日",
        "0323" => "星期六、星期日",
        "0324" => "星期六、星期日",
        "0330" => "星期六、星期日",
        "0331" => "星期六、星期日",
        "0404" => "兒童節",
        "0405" => "民族掃墓節（清明節）",
        "0406" => "星期六、星期日",
        "0407" => "星期六、星期日",
        "0413" => "星期六、星期日",
        "0414" => "星期六、星期日",
        "0420" => "星期六、星期日",
        "0421" => "星期六、星期日",
        "0427" => "星期六、星期日",
        "0428" => "星期六、星期日",
        "0501" => "勞動節",
        "0504" => "星期六、星期日",
        "0505" => "星期六、星期日",
        "0511" => "星期六、星期日",
        "0512" => "星期六、星期日",
        "0518" => "星期六、星期日",
        "0519" => "星期六、星期日",
        "0525" => "星期六、星期日",
        "0526" => "星期六、星期日",
        "0601" => "星期六、星期日",
        "0602" => "星期六、星期日",
        "0607" => "端午節",
        "0608" => "星期六、星期日",
        "0609" => "星期六、星期日",
        "0615" => "星期六、星期日",
        "0616" => "星期六、星期日",
        "0622" => "星期六、星期日",
        "0623" => "星期六、星期日",
        "0629" => "星期六、星期日",
        "0630" => "星期六、星期日",
        "0706" => "星期六、星期日",
        "0707" => "星期六、星期日",
        "0713" => "星期六、星期日",
        "0714" => "星期六、星期日",
        "0720" => "星期六、星期日",
        "0721" => "星期六、星期日",
        "0727" => "星期六、星期日",
        "0728" => "星期六、星期日",
        "0803" => "星期六、星期日",
        "0804" => "星期六、星期日",
        "0810" => "星期六、星期日",
        "0811" => "星期六、星期日",
        "0817" => "星期六、星期日",
        "0818" => "星期六、星期日",
        "0824" => "星期六、星期日",
        "0825" => "星期六、星期日",
        "0831" => "星期六、星期日",
        "0901" => "星期六、星期日",
        "0903" => "軍人節",
        "0907" => "星期六、星期日",
        "0908" => "星期六、星期日",
        "0913" => "中秋節",
        "0914" => "星期六、星期日",
        "0915" => "星期六、星期日",
        "0921" => "星期六、星期日",
        "0922" => "星期六、星期日",
        "0928" => "星期六、星期日",
        "0929" => "星期六、星期日",
        "1005" => "",
        "1006" => "星期六、星期日",
        "1010" => "國慶日",
        "1011" => "調整放假日",
        "1012" => "星期六、星期日",
        "1013" => "星期六、星期日",
        "1019" => "星期六、星期日",
        "1020" => "星期六、星期日",
        "1026" => "星期六、星期日",
        "1027" => "星期六、星期日",
        "1102" => "星期六、星期日",
        "1103" => "星期六、星期日",
        "1109" => "星期六、星期日",
        "1110" => "星期六、星期日",
        "1116" => "星期六、星期日",
        "1117" => "星期六、星期日",
        "1123" => "星期六、星期日",
        "1124" => "星期六、星期日",
        "1130" => "星期六、星期日",
        "1201" => "星期六、星期日",
        "1207" => "星期六、星期日",
        "1208" => "星期六、星期日",
        "1214" => "星期六、星期日",
        "1215" => "星期六、星期日",
        "1221" => "星期六、星期日",
        "1222" => "星期六、星期日",
        "1228" => "星期六、星期日",
        "1229" => "星期六、星期日",
    },
    2020 => {
        "0101" => "中華民國開國紀念日",
        "0104" => "星期六、星期日",
        "0105" => "星期六、星期日",
        "0111" => "星期六、星期日",
        "0112" => "星期六、星期日",
        "0118" => "星期六、星期日",
        "0119" => "星期六、星期日",
        "0123" => "調整放假日",
        "0124" => "農曆除夕",
        "0125" => "春節",
        "0126" => "春節",
        "0127" => "春節",
        "0128" => "補假",
        "0129" => "補假",
        "0201" => "星期六、星期日",
        "0202" => "星期六、星期日",
        "0208" => "星期六、星期日",
        "0209" => "星期六、星期日",
        "0215" => "",
        "0216" => "星期六、星期日",
        "0222" => "星期六、星期日",
        "0223" => "星期六、星期日",
        "0228" => "和平紀念日",
        "0229" => "星期六、星期日",
        "0301" => "星期六、星期日",
        "0307" => "星期六、星期日",
        "0308" => "星期六、星期日",
        "0314" => "星期六、星期日",
        "0315" => "星期六、星期日",
        "0321" => "星期六、星期日",
        "0322" => "星期六、星期日",
        "0328" => "星期六、星期日",
        "0329" => "星期六、星期日",
        "0402" => "補假",
        "0403" => "放假之紀念日及節日",
        "0404" => "兒童節及民族掃墓節",
        "0405" => "星期六、星期日",
        "0411" => "星期六、星期日",
        "0412" => "星期六、星期日",
        "0418" => "星期六、星期日",
        "0419" => "星期六、星期日",
        "0425" => "星期六、星期日",
        "0426" => "星期六、星期日",
        "0501" => "勞動節",
        "0502" => "星期六、星期日",
        "0503" => "星期六、星期日",
        "0509" => "星期六、星期日",
        "0510" => "星期六、星期日",
        "0516" => "星期六、星期日",
        "0517" => "星期六、星期日",
        "0523" => "星期六、星期日",
        "0524" => "星期六、星期日",
        "0530" => "星期六、星期日",
        "0531" => "星期六、星期日",
        "0606" => "星期六、星期日",
        "0607" => "星期六、星期日",
        "0613" => "星期六、星期日",
        "0614" => "星期六、星期日",
        "0620" => "",
        "0621" => "星期六、星期日",
        "0625" => "端午節",
        "0626" => "調整放假日",
        "0627" => "星期六、星期日",
        "0628" => "星期六、星期日",
        "0704" => "星期六、星期日",
        "0705" => "星期六、星期日",
        "0711" => "星期六、星期日",
        "0712" => "星期六、星期日",
        "0718" => "星期六、星期日",
        "0719" => "星期六、星期日",
        "0725" => "星期六、星期日",
        "0726" => "星期六、星期日",
        "0801" => "星期六、星期日",
        "0802" => "星期六、星期日",
        "0808" => "星期六、星期日",
        "0809" => "星期六、星期日",
        "0815" => "星期六、星期日",
        "0816" => "星期六、星期日",
        "0822" => "星期六、星期日",
        "0823" => "星期六、星期日",
        "0829" => "星期六、星期日",
        "0830" => "星期六、星期日",
        "0903" => "軍人節",
        "0905" => "星期六、星期日",
        "0906" => "星期六、星期日",
        "0912" => "星期六、星期日",
        "0913" => "星期六、星期日",
        "0919" => "星期六、星期日",
        "0920" => "星期六、星期日",
        "0926" => "",
        "0927" => "星期六、星期日",
        "1001" => "中秋節",
        "1002" => "調整放假日",
        "1003" => "星期六、星期日",
        "1004" => "星期六、星期日",
        "1009" => "補假",
        "1010" => "國慶日",
        "1011" => "星期六、星期日",
        "1017" => "星期六、星期日",
        "1018" => "星期六、星期日",
        "1024" => "星期六、星期日",
        "1025" => "星期六、星期日",
        "1031" => "星期六、星期日",
        "1101" => "星期六、星期日",
        "1107" => "星期六、星期日",
        "1108" => "星期六、星期日",
        "1114" => "星期六、星期日",
        "1115" => "星期六、星期日",
        "1121" => "星期六、星期日",
        "1122" => "星期六、星期日",
        "1128" => "星期六、星期日",
        "1129" => "星期六、星期日",
        "1205" => "星期六、星期日",
        "1206" => "星期六、星期日",
        "1212" => "星期六、星期日",
        "1213" => "星期六、星期日",
        "1219" => "星期六、星期日",
        "1220" => "星期六、星期日",
        "1226" => "星期六、星期日",
        "1227" => "星期六、星期日",
    },
);

$CAL{2021} = {
    '0101' => '中華民國開國紀念日',
    '0210' => '春節',
    '0211' => '春節',
    '0212' => '春節',
    '0213' => '春節',
    '0214' => '春節',
    '0215' => '春節',
    '0216' => '春節',
    '0220' => '',
    '0228' => '和平紀念日',
    '0301' => '調整放假',
    '0402' => '調整放假',
    '0404' => '兒童節',
    '0405' => '調整放假',
    '0614' => '端午節',
    '0911' => ''
    '0920' => '調整放假'
    '0921' => '中秋節',
    '1010' => '國慶日',
    '1011' => '調整放假',
};

sub new { bless {}, shift };

sub holidays {
    my (undef, $year) = @_;
    return tw_holidays($year);
}

sub is_holiday {
    my (undef, $year, $month, $day) = @_;
    return is_tw_holiday($year, $month, $day);
}

my %_reified;
sub tw_holidays {
    my ($year) = @_;
    $year = sprintf('%04d', $year);

    unless ($_reified{$year}) {
        my %holidays = %NATIONAL;

        my $dt = DateTime->new( year => $year, month => 1, day => 1, time_zone => 'Asia/Taipei' );
        while ($dt->year == $year) {
            my $h = __is_tw_holiday($dt);
            if (defined($h)) {
                my $mmdd = $dt->strftime('%m%d');
                $holidays{$mmdd} = $h;
            }

            $dt->add(days => 1);
        }

        $_reified{$year} = \%holidays;
    }

    return $_reified{$year};
}

sub is_tw_holiday {
    my ($year, $month, $day) = @_;
    return __is_tw_holiday(
        DateTime->new(
            year => $year,
            month => $month,
            day => $day,
            time_zone => 'Asia/Taipei',
        )
    );
}

sub __is_tw_holiday {
    my ($dt) = @_;
    my $mmdd = $dt->strftime('%m%d');
    my $year = $dt->year;
    return $CAL{$year}{$mmdd} // $NATIONAL{$mmdd} // __is_qingming($dt) // __is_tw_lunar_holiday($dt)
}

sub __is_tw_lunar_holiday {
    my ($dt) = @_;
    my $lunar_date = DateTime::Calendar::Chinese->from_object(object => $dt);
    return undef if $lunar_date->leap_month;
    my $lunar_mmdd = sprintf('%02d%02d', $lunar_date->month, $lunar_date->day);
    return $FOLK_LUNAR{$lunar_mmdd};
}

sub __is_qingming {
    # Thanks Wei-Hon Chen for the formula.
    my $dt = $_[0];
    return undef unless $dt->month == 4 && 3 < $dt->day && $dt->day < 6;
    my $year = $dt->year;
    die "Unsupported" if $year < 1901 || 2100 < $year;
    my $Y = ($year % 100);
    my $C = (1901 <= $year && $year < 2001) ? 5.59 : 4.81;
    my $n = int($Y * 0.2422 + 4.81) - int($Y / 4);
    return $dt->day == $n ? '民族掃墓節' : undef;
}

1;

__END__

=head1 NAME

Date::Holidays::TW - Determine whether it is Taiwan Holidays or not.

=head1 SYNOPSIS

This module can be used by itself:

    use Date::Holidays::TW qw(is_tw_holiday);
    if ( is_tw_holiday(2020, 6, 25) ) {
        ...
    }

Or via C<Date::Holidays>

    my $dh = Date::Holidays->new( countrycode => 'TW' );
    if ($dh->is_holiday( 2020, 6, 25 )) {
        ...
    }

=head1 DESCRIPTION

This module provides functions to look into Taiwan holiday calendars
for known holidays. It could be used by itself, or under via
L<Date::Holidays> module.

Caveat: Due to the rule of weekend-compensation and the fact that the
majority of holidays are defined by Chinese calendar (Lunar), it
requires some non-trivial amount of computation to correctly determine
whether the given date is an holiday or not -- which is not
implemented at this version.

The current implementation includes all known holidays of year 2019
and 2020 as a lookup table and should therefore correctly determine
holidays in those 2 years. It should also determine most of the future
updates correct by some basic compuation, except for the ones
generated by the weekend-compensation rule.

Conventionally the holiday calendar for the next year is announcend at
the end of June and we could start to mix the new information into the
lookup table in this module.

Generally speaking, queries for far future should be avoided.

=head1 EXPORTABLE FUNCTIONS

=head2 is_tw_holiday

Usage:

    my $holiday_name = is_tw_holiday( $year, $month, $day );

This subroutine returns the name of the holiday for the given day
if it is a holiday. Otherwise it returns undef.

=head2 tw_holidays

Usage:

    my $holidays = tw_holidays( $year );

This retrieve all Taiwan holidays of given year as a HashRef.
With keys being Month + Day as 4-digit string and values being
the name of the corresponding holiday.

=head1 METHODS

=head2 is_holiday

Usage:

    $o = Date::Holidays::TW->new();
    $res = $o->is_holiday( $year, $month, $day );

This does the same thing as function C<is_tw_holiday>.

=head2 holidays

Usage:

    $o = Date::Holidays::TW->new();
    $res = $o->holidays( $year );

This does the same thing as function C<tw_holidays>.

=head1 SEE ALSO

L<Date::Holidays>, L<https://www.dgpa.gov.tw/informationlist?uid=30>

=head1 AUTHOR

Kang-min Liu C<< <gugod@gugod.org> >>

Wei-Hon Chen

=head1 LICENSE

The MIT License

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut
