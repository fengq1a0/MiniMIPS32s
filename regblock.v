`include "defines.v"
module cache_reg(
    input  wire         clk,
    input  wire [6:0]   addr,
    output  reg [2:0]   rdata,
    input  wire [2:0]   wdata,
    input  wire         wen,
    input  wire         rst
);
    reg[127:0] lru;
    reg[127:0] w0va;
    reg[127:0] w1va; 
    
    always @ (posedge clk)
    begin
        if (~rst) begin
            lru  <= 0;
            w0va <= 0;
            w1va <= 0;
        end else
        case (addr)
0   :begin if (wen) begin rdata<=wdata; {lru[0],w1va[0],w0va[0]} <= wdata;       end else rdata<={lru[0],w1va[0],w0va[0]};      end
1   :begin if (wen) begin rdata<=wdata; {lru[1],w1va[1],w0va[1]} <= wdata;       end else rdata<={lru[1],w1va[1],w0va[1]};      end
2   :begin if (wen) begin rdata<=wdata; {lru[2],w1va[2],w0va[2]} <= wdata;       end else rdata<={lru[2],w1va[2],w0va[2]};      end
3   :begin if (wen) begin rdata<=wdata; {lru[3],w1va[3],w0va[3]} <= wdata;       end else rdata<={lru[3],w1va[3],w0va[3]};      end
4   :begin if (wen) begin rdata<=wdata; {lru[4],w1va[4],w0va[4]} <= wdata;       end else rdata<={lru[4],w1va[4],w0va[4]};      end
5   :begin if (wen) begin rdata<=wdata; {lru[5],w1va[5],w0va[5]} <= wdata;       end else rdata<={lru[5],w1va[5],w0va[5]};      end
6   :begin if (wen) begin rdata<=wdata; {lru[6],w1va[6],w0va[6]} <= wdata;       end else rdata<={lru[6],w1va[6],w0va[6]};      end
7   :begin if (wen) begin rdata<=wdata; {lru[7],w1va[7],w0va[7]} <= wdata;       end else rdata<={lru[7],w1va[7],w0va[7]};      end
8   :begin if (wen) begin rdata<=wdata; {lru[8],w1va[8],w0va[8]} <= wdata;       end else rdata<={lru[8],w1va[8],w0va[8]};      end
9   :begin if (wen) begin rdata<=wdata; {lru[9],w1va[9],w0va[9]} <= wdata;       end else rdata<={lru[9],w1va[9],w0va[9]};      end
10  :begin if (wen) begin rdata<=wdata; {lru[10],w1va[10],w0va[10]} <= wdata;    end else rdata<={lru[10],w1va[10],w0va[10]};   end
11  :begin if (wen) begin rdata<=wdata; {lru[11],w1va[11],w0va[11]} <= wdata;    end else rdata<={lru[11],w1va[11],w0va[11]};   end
12  :begin if (wen) begin rdata<=wdata; {lru[12],w1va[12],w0va[12]} <= wdata;    end else rdata<={lru[12],w1va[12],w0va[12]};   end
13  :begin if (wen) begin rdata<=wdata; {lru[13],w1va[13],w0va[13]} <= wdata;    end else rdata<={lru[13],w1va[13],w0va[13]};   end
14  :begin if (wen) begin rdata<=wdata; {lru[14],w1va[14],w0va[14]} <= wdata;    end else rdata<={lru[14],w1va[14],w0va[14]};   end
15  :begin if (wen) begin rdata<=wdata; {lru[15],w1va[15],w0va[15]} <= wdata;    end else rdata<={lru[15],w1va[15],w0va[15]};   end
16  :begin if (wen) begin rdata<=wdata; {lru[16],w1va[16],w0va[16]} <= wdata;    end else rdata<={lru[16],w1va[16],w0va[16]};   end
17  :begin if (wen) begin rdata<=wdata; {lru[17],w1va[17],w0va[17]} <= wdata;    end else rdata<={lru[17],w1va[17],w0va[17]};   end
18  :begin if (wen) begin rdata<=wdata; {lru[18],w1va[18],w0va[18]} <= wdata;    end else rdata<={lru[18],w1va[18],w0va[18]};   end
19  :begin if (wen) begin rdata<=wdata; {lru[19],w1va[19],w0va[19]} <= wdata;    end else rdata<={lru[19],w1va[19],w0va[19]};   end
20  :begin if (wen) begin rdata<=wdata; {lru[20],w1va[20],w0va[20]} <= wdata;    end else rdata<={lru[20],w1va[20],w0va[20]};   end
21  :begin if (wen) begin rdata<=wdata; {lru[21],w1va[21],w0va[21]} <= wdata;    end else rdata<={lru[21],w1va[21],w0va[21]};   end
22  :begin if (wen) begin rdata<=wdata; {lru[22],w1va[22],w0va[22]} <= wdata;    end else rdata<={lru[22],w1va[22],w0va[22]};   end
23  :begin if (wen) begin rdata<=wdata; {lru[23],w1va[23],w0va[23]} <= wdata;    end else rdata<={lru[23],w1va[23],w0va[23]};   end
24  :begin if (wen) begin rdata<=wdata; {lru[24],w1va[24],w0va[24]} <= wdata;    end else rdata<={lru[24],w1va[24],w0va[24]};   end
25  :begin if (wen) begin rdata<=wdata; {lru[25],w1va[25],w0va[25]} <= wdata;    end else rdata<={lru[25],w1va[25],w0va[25]};   end
26  :begin if (wen) begin rdata<=wdata; {lru[26],w1va[26],w0va[26]} <= wdata;    end else rdata<={lru[26],w1va[26],w0va[26]};   end
27  :begin if (wen) begin rdata<=wdata; {lru[27],w1va[27],w0va[27]} <= wdata;    end else rdata<={lru[27],w1va[27],w0va[27]};   end
28  :begin if (wen) begin rdata<=wdata; {lru[28],w1va[28],w0va[28]} <= wdata;    end else rdata<={lru[28],w1va[28],w0va[28]};   end
29  :begin if (wen) begin rdata<=wdata; {lru[29],w1va[29],w0va[29]} <= wdata;    end else rdata<={lru[29],w1va[29],w0va[29]};   end
30  :begin if (wen) begin rdata<=wdata; {lru[30],w1va[30],w0va[30]} <= wdata;    end else rdata<={lru[30],w1va[30],w0va[30]};   end
31  :begin if (wen) begin rdata<=wdata; {lru[31],w1va[31],w0va[31]} <= wdata;    end else rdata<={lru[31],w1va[31],w0va[31]};   end
32  :begin if (wen) begin rdata<=wdata; {lru[32],w1va[32],w0va[32]} <= wdata;    end else rdata<={lru[32],w1va[32],w0va[32]};   end
33  :begin if (wen) begin rdata<=wdata; {lru[33],w1va[33],w0va[33]} <= wdata;    end else rdata<={lru[33],w1va[33],w0va[33]};   end
34  :begin if (wen) begin rdata<=wdata; {lru[34],w1va[34],w0va[34]} <= wdata;    end else rdata<={lru[34],w1va[34],w0va[34]};   end
35  :begin if (wen) begin rdata<=wdata; {lru[35],w1va[35],w0va[35]} <= wdata;    end else rdata<={lru[35],w1va[35],w0va[35]};   end
36  :begin if (wen) begin rdata<=wdata; {lru[36],w1va[36],w0va[36]} <= wdata;    end else rdata<={lru[36],w1va[36],w0va[36]};   end
37  :begin if (wen) begin rdata<=wdata; {lru[37],w1va[37],w0va[37]} <= wdata;    end else rdata<={lru[37],w1va[37],w0va[37]};   end
38  :begin if (wen) begin rdata<=wdata; {lru[38],w1va[38],w0va[38]} <= wdata;    end else rdata<={lru[38],w1va[38],w0va[38]};   end
39  :begin if (wen) begin rdata<=wdata; {lru[39],w1va[39],w0va[39]} <= wdata;    end else rdata<={lru[39],w1va[39],w0va[39]};   end
40  :begin if (wen) begin rdata<=wdata; {lru[40],w1va[40],w0va[40]} <= wdata;    end else rdata<={lru[40],w1va[40],w0va[40]};   end
41  :begin if (wen) begin rdata<=wdata; {lru[41],w1va[41],w0va[41]} <= wdata;    end else rdata<={lru[41],w1va[41],w0va[41]};   end
42  :begin if (wen) begin rdata<=wdata; {lru[42],w1va[42],w0va[42]} <= wdata;    end else rdata<={lru[42],w1va[42],w0va[42]};   end
43  :begin if (wen) begin rdata<=wdata; {lru[43],w1va[43],w0va[43]} <= wdata;    end else rdata<={lru[43],w1va[43],w0va[43]};   end
44  :begin if (wen) begin rdata<=wdata; {lru[44],w1va[44],w0va[44]} <= wdata;    end else rdata<={lru[44],w1va[44],w0va[44]};   end
45  :begin if (wen) begin rdata<=wdata; {lru[45],w1va[45],w0va[45]} <= wdata;    end else rdata<={lru[45],w1va[45],w0va[45]};   end
46  :begin if (wen) begin rdata<=wdata; {lru[46],w1va[46],w0va[46]} <= wdata;    end else rdata<={lru[46],w1va[46],w0va[46]};   end
47  :begin if (wen) begin rdata<=wdata; {lru[47],w1va[47],w0va[47]} <= wdata;    end else rdata<={lru[47],w1va[47],w0va[47]};   end
48  :begin if (wen) begin rdata<=wdata; {lru[48],w1va[48],w0va[48]} <= wdata;    end else rdata<={lru[48],w1va[48],w0va[48]};   end
49  :begin if (wen) begin rdata<=wdata; {lru[49],w1va[49],w0va[49]} <= wdata;    end else rdata<={lru[49],w1va[49],w0va[49]};   end
50  :begin if (wen) begin rdata<=wdata; {lru[50],w1va[50],w0va[50]} <= wdata;    end else rdata<={lru[50],w1va[50],w0va[50]};   end
51  :begin if (wen) begin rdata<=wdata; {lru[51],w1va[51],w0va[51]} <= wdata;    end else rdata<={lru[51],w1va[51],w0va[51]};   end
52  :begin if (wen) begin rdata<=wdata; {lru[52],w1va[52],w0va[52]} <= wdata;    end else rdata<={lru[52],w1va[52],w0va[52]};   end
53  :begin if (wen) begin rdata<=wdata; {lru[53],w1va[53],w0va[53]} <= wdata;    end else rdata<={lru[53],w1va[53],w0va[53]};   end
54  :begin if (wen) begin rdata<=wdata; {lru[54],w1va[54],w0va[54]} <= wdata;    end else rdata<={lru[54],w1va[54],w0va[54]};   end
55  :begin if (wen) begin rdata<=wdata; {lru[55],w1va[55],w0va[55]} <= wdata;    end else rdata<={lru[55],w1va[55],w0va[55]};   end
56  :begin if (wen) begin rdata<=wdata; {lru[56],w1va[56],w0va[56]} <= wdata;    end else rdata<={lru[56],w1va[56],w0va[56]};   end
57  :begin if (wen) begin rdata<=wdata; {lru[57],w1va[57],w0va[57]} <= wdata;    end else rdata<={lru[57],w1va[57],w0va[57]};   end
58  :begin if (wen) begin rdata<=wdata; {lru[58],w1va[58],w0va[58]} <= wdata;    end else rdata<={lru[58],w1va[58],w0va[58]};   end
59  :begin if (wen) begin rdata<=wdata; {lru[59],w1va[59],w0va[59]} <= wdata;    end else rdata<={lru[59],w1va[59],w0va[59]};   end
60  :begin if (wen) begin rdata<=wdata; {lru[60],w1va[60],w0va[60]} <= wdata;    end else rdata<={lru[60],w1va[60],w0va[60]};   end
61  :begin if (wen) begin rdata<=wdata; {lru[61],w1va[61],w0va[61]} <= wdata;    end else rdata<={lru[61],w1va[61],w0va[61]};   end
62  :begin if (wen) begin rdata<=wdata; {lru[62],w1va[62],w0va[62]} <= wdata;    end else rdata<={lru[62],w1va[62],w0va[62]};   end
63  :begin if (wen) begin rdata<=wdata; {lru[63],w1va[63],w0va[63]} <= wdata;    end else rdata<={lru[63],w1va[63],w0va[63]};   end
64  :begin if (wen) begin rdata<=wdata; {lru[64],w1va[64],w0va[64]} <= wdata;    end else rdata<={lru[64],w1va[64],w0va[64]};   end
65  :begin if (wen) begin rdata<=wdata; {lru[65],w1va[65],w0va[65]} <= wdata;    end else rdata<={lru[65],w1va[65],w0va[65]};   end
66  :begin if (wen) begin rdata<=wdata; {lru[66],w1va[66],w0va[66]} <= wdata;    end else rdata<={lru[66],w1va[66],w0va[66]};   end
67  :begin if (wen) begin rdata<=wdata; {lru[67],w1va[67],w0va[67]} <= wdata;    end else rdata<={lru[67],w1va[67],w0va[67]};   end
68  :begin if (wen) begin rdata<=wdata; {lru[68],w1va[68],w0va[68]} <= wdata;    end else rdata<={lru[68],w1va[68],w0va[68]};   end
69  :begin if (wen) begin rdata<=wdata; {lru[69],w1va[69],w0va[69]} <= wdata;    end else rdata<={lru[69],w1va[69],w0va[69]};   end
70  :begin if (wen) begin rdata<=wdata; {lru[70],w1va[70],w0va[70]} <= wdata;    end else rdata<={lru[70],w1va[70],w0va[70]};   end
71  :begin if (wen) begin rdata<=wdata; {lru[71],w1va[71],w0va[71]} <= wdata;    end else rdata<={lru[71],w1va[71],w0va[71]};   end
72  :begin if (wen) begin rdata<=wdata; {lru[72],w1va[72],w0va[72]} <= wdata;    end else rdata<={lru[72],w1va[72],w0va[72]};   end
73  :begin if (wen) begin rdata<=wdata; {lru[73],w1va[73],w0va[73]} <= wdata;    end else rdata<={lru[73],w1va[73],w0va[73]};   end
74  :begin if (wen) begin rdata<=wdata; {lru[74],w1va[74],w0va[74]} <= wdata;    end else rdata<={lru[74],w1va[74],w0va[74]};   end
75  :begin if (wen) begin rdata<=wdata; {lru[75],w1va[75],w0va[75]} <= wdata;    end else rdata<={lru[75],w1va[75],w0va[75]};   end
76  :begin if (wen) begin rdata<=wdata; {lru[76],w1va[76],w0va[76]} <= wdata;    end else rdata<={lru[76],w1va[76],w0va[76]};   end
77  :begin if (wen) begin rdata<=wdata; {lru[77],w1va[77],w0va[77]} <= wdata;    end else rdata<={lru[77],w1va[77],w0va[77]};   end
78  :begin if (wen) begin rdata<=wdata; {lru[78],w1va[78],w0va[78]} <= wdata;    end else rdata<={lru[78],w1va[78],w0va[78]};   end
79  :begin if (wen) begin rdata<=wdata; {lru[79],w1va[79],w0va[79]} <= wdata;    end else rdata<={lru[79],w1va[79],w0va[79]};   end
80  :begin if (wen) begin rdata<=wdata; {lru[80],w1va[80],w0va[80]} <= wdata;    end else rdata<={lru[80],w1va[80],w0va[80]};   end
81  :begin if (wen) begin rdata<=wdata; {lru[81],w1va[81],w0va[81]} <= wdata;    end else rdata<={lru[81],w1va[81],w0va[81]};   end
82  :begin if (wen) begin rdata<=wdata; {lru[82],w1va[82],w0va[82]} <= wdata;    end else rdata<={lru[82],w1va[82],w0va[82]};   end
83  :begin if (wen) begin rdata<=wdata; {lru[83],w1va[83],w0va[83]} <= wdata;    end else rdata<={lru[83],w1va[83],w0va[83]};   end
84  :begin if (wen) begin rdata<=wdata; {lru[84],w1va[84],w0va[84]} <= wdata;    end else rdata<={lru[84],w1va[84],w0va[84]};   end
85  :begin if (wen) begin rdata<=wdata; {lru[85],w1va[85],w0va[85]} <= wdata;    end else rdata<={lru[85],w1va[85],w0va[85]};   end
86  :begin if (wen) begin rdata<=wdata; {lru[86],w1va[86],w0va[86]} <= wdata;    end else rdata<={lru[86],w1va[86],w0va[86]};   end
87  :begin if (wen) begin rdata<=wdata; {lru[87],w1va[87],w0va[87]} <= wdata;    end else rdata<={lru[87],w1va[87],w0va[87]};   end
88  :begin if (wen) begin rdata<=wdata; {lru[88],w1va[88],w0va[88]} <= wdata;    end else rdata<={lru[88],w1va[88],w0va[88]};   end
89  :begin if (wen) begin rdata<=wdata; {lru[89],w1va[89],w0va[89]} <= wdata;    end else rdata<={lru[89],w1va[89],w0va[89]};   end
90  :begin if (wen) begin rdata<=wdata; {lru[90],w1va[90],w0va[90]} <= wdata;    end else rdata<={lru[90],w1va[90],w0va[90]};   end
91  :begin if (wen) begin rdata<=wdata; {lru[91],w1va[91],w0va[91]} <= wdata;    end else rdata<={lru[91],w1va[91],w0va[91]};   end
92  :begin if (wen) begin rdata<=wdata; {lru[92],w1va[92],w0va[92]} <= wdata;    end else rdata<={lru[92],w1va[92],w0va[92]};   end
93  :begin if (wen) begin rdata<=wdata; {lru[93],w1va[93],w0va[93]} <= wdata;    end else rdata<={lru[93],w1va[93],w0va[93]};   end
94  :begin if (wen) begin rdata<=wdata; {lru[94],w1va[94],w0va[94]} <= wdata;    end else rdata<={lru[94],w1va[94],w0va[94]};   end
95  :begin if (wen) begin rdata<=wdata; {lru[95],w1va[95],w0va[95]} <= wdata;    end else rdata<={lru[95],w1va[95],w0va[95]};   end
96  :begin if (wen) begin rdata<=wdata; {lru[96],w1va[96],w0va[96]} <= wdata;    end else rdata<={lru[96],w1va[96],w0va[96]};   end
97  :begin if (wen) begin rdata<=wdata; {lru[97],w1va[97],w0va[97]} <= wdata;    end else rdata<={lru[97],w1va[97],w0va[97]};   end
98  :begin if (wen) begin rdata<=wdata; {lru[98],w1va[98],w0va[98]} <= wdata;    end else rdata<={lru[98],w1va[98],w0va[98]};   end
99  :begin if (wen) begin rdata<=wdata; {lru[99],w1va[99],w0va[99]} <= wdata;    end else rdata<={lru[99],w1va[99],w0va[99]};   end
100 :begin if (wen) begin rdata<=wdata; {lru[100],w1va[100],w0va[100]} <= wdata; end else rdata<={lru[100],w1va[100],w0va[100]};end
101 :begin if (wen) begin rdata<=wdata; {lru[101],w1va[101],w0va[101]} <= wdata; end else rdata<={lru[101],w1va[101],w0va[101]};end
102 :begin if (wen) begin rdata<=wdata; {lru[102],w1va[102],w0va[102]} <= wdata; end else rdata<={lru[102],w1va[102],w0va[102]};end
103 :begin if (wen) begin rdata<=wdata; {lru[103],w1va[103],w0va[103]} <= wdata; end else rdata<={lru[103],w1va[103],w0va[103]};end
104 :begin if (wen) begin rdata<=wdata; {lru[104],w1va[104],w0va[104]} <= wdata; end else rdata<={lru[104],w1va[104],w0va[104]};end
105 :begin if (wen) begin rdata<=wdata; {lru[105],w1va[105],w0va[105]} <= wdata; end else rdata<={lru[105],w1va[105],w0va[105]};end
106 :begin if (wen) begin rdata<=wdata; {lru[106],w1va[106],w0va[106]} <= wdata; end else rdata<={lru[106],w1va[106],w0va[106]};end
107 :begin if (wen) begin rdata<=wdata; {lru[107],w1va[107],w0va[107]} <= wdata; end else rdata<={lru[107],w1va[107],w0va[107]};end
108 :begin if (wen) begin rdata<=wdata; {lru[108],w1va[108],w0va[108]} <= wdata; end else rdata<={lru[108],w1va[108],w0va[108]};end
109 :begin if (wen) begin rdata<=wdata; {lru[109],w1va[109],w0va[109]} <= wdata; end else rdata<={lru[109],w1va[109],w0va[109]};end
110 :begin if (wen) begin rdata<=wdata; {lru[110],w1va[110],w0va[110]} <= wdata; end else rdata<={lru[110],w1va[110],w0va[110]};end
111 :begin if (wen) begin rdata<=wdata; {lru[111],w1va[111],w0va[111]} <= wdata; end else rdata<={lru[111],w1va[111],w0va[111]};end
112 :begin if (wen) begin rdata<=wdata; {lru[112],w1va[112],w0va[112]} <= wdata; end else rdata<={lru[112],w1va[112],w0va[112]};end
113 :begin if (wen) begin rdata<=wdata; {lru[113],w1va[113],w0va[113]} <= wdata; end else rdata<={lru[113],w1va[113],w0va[113]};end
114 :begin if (wen) begin rdata<=wdata; {lru[114],w1va[114],w0va[114]} <= wdata; end else rdata<={lru[114],w1va[114],w0va[114]};end
115 :begin if (wen) begin rdata<=wdata; {lru[115],w1va[115],w0va[115]} <= wdata; end else rdata<={lru[115],w1va[115],w0va[115]};end
116 :begin if (wen) begin rdata<=wdata; {lru[116],w1va[116],w0va[116]} <= wdata; end else rdata<={lru[116],w1va[116],w0va[116]};end
117 :begin if (wen) begin rdata<=wdata; {lru[117],w1va[117],w0va[117]} <= wdata; end else rdata<={lru[117],w1va[117],w0va[117]};end
118 :begin if (wen) begin rdata<=wdata; {lru[118],w1va[118],w0va[118]} <= wdata; end else rdata<={lru[118],w1va[118],w0va[118]};end
119 :begin if (wen) begin rdata<=wdata; {lru[119],w1va[119],w0va[119]} <= wdata; end else rdata<={lru[119],w1va[119],w0va[119]};end
120 :begin if (wen) begin rdata<=wdata; {lru[120],w1va[120],w0va[120]} <= wdata; end else rdata<={lru[120],w1va[120],w0va[120]};end
121 :begin if (wen) begin rdata<=wdata; {lru[121],w1va[121],w0va[121]} <= wdata; end else rdata<={lru[121],w1va[121],w0va[121]};end
122 :begin if (wen) begin rdata<=wdata; {lru[122],w1va[122],w0va[122]} <= wdata; end else rdata<={lru[122],w1va[122],w0va[122]};end
123 :begin if (wen) begin rdata<=wdata; {lru[123],w1va[123],w0va[123]} <= wdata; end else rdata<={lru[123],w1va[123],w0va[123]};end
124 :begin if (wen) begin rdata<=wdata; {lru[124],w1va[124],w0va[124]} <= wdata; end else rdata<={lru[124],w1va[124],w0va[124]};end
125 :begin if (wen) begin rdata<=wdata; {lru[125],w1va[125],w0va[125]} <= wdata; end else rdata<={lru[125],w1va[125],w0va[125]};end
126 :begin if (wen) begin rdata<=wdata; {lru[126],w1va[126],w0va[126]} <= wdata; end else rdata<={lru[126],w1va[126],w0va[126]};end
127 :begin if (wen) begin rdata<=wdata; {lru[127],w1va[127],w0va[127]} <= wdata; end else rdata<={lru[127],w1va[127],w0va[127]};end

        endcase
    end


endmodule


