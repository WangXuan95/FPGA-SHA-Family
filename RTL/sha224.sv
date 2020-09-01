`timescale 1ns/1ns

module sha224(
    input  wire         rst,
    input  wire         clk,
    input  wire         tvalid,
    output wire         tready,
    input  wire         tlast,
    input  wire [ 31:0] tid,
    input  wire [  7:0] tdata,
    output reg          ovalid,
    output reg  [ 31:0] oid,
    output reg  [ 60:0] olen,
    output wire [223:0] osha
);

function automatic logic [31:0] SSIG0(input [31:0] x);
    return {x[6:0],x[31:7]} ^ {x[17:0],x[31:18]} ^ {3'h0,x[31:3]};
endfunction

function automatic logic [31:0] SSIG1(input [31:0] x);
    return {x[16:0],x[31:17]} ^ {x[18:0],x[31:19]} ^ {10'h0,x[31:10]};
endfunction

function automatic logic [31:0] BSIG0(input [31:0] x);
    return {x[1:0],x[31:2]} ^ {x[12:0],x[31:13]} ^ {x[21:0],x[31:22]};
endfunction

function automatic logic [31:0] BSIG1(input [31:0] x);
    return {x[5:0],x[31:6]} ^ {x[10:0],x[31:11]} ^ {x[24:0],x[31:25]};
endfunction

wire [31:0] k [64];
assign k[ 0] = 'h428a2f98;
assign k[ 1] = 'h71374491;
assign k[ 2] = 'hb5c0fbcf;
assign k[ 3] = 'he9b5dba5;
assign k[ 4] = 'h3956c25b;
assign k[ 5] = 'h59f111f1;
assign k[ 6] = 'h923f82a4;
assign k[ 7] = 'hab1c5ed5;
assign k[ 8] = 'hd807aa98;
assign k[ 9] = 'h12835b01;
assign k[10] = 'h243185be;
assign k[11] = 'h550c7dc3;
assign k[12] = 'h72be5d74;
assign k[13] = 'h80deb1fe;
assign k[14] = 'h9bdc06a7;
assign k[15] = 'hc19bf174;
assign k[16] = 'he49b69c1;
assign k[17] = 'hefbe4786;
assign k[18] = 'h0fc19dc6;
assign k[19] = 'h240ca1cc;
assign k[20] = 'h2de92c6f;
assign k[21] = 'h4a7484aa;
assign k[22] = 'h5cb0a9dc;
assign k[23] = 'h76f988da;
assign k[24] = 'h983e5152;
assign k[25] = 'ha831c66d;
assign k[26] = 'hb00327c8;
assign k[27] = 'hbf597fc7;
assign k[28] = 'hc6e00bf3;
assign k[29] = 'hd5a79147;
assign k[30] = 'h06ca6351;
assign k[31] = 'h14292967;
assign k[32] = 'h27b70a85;
assign k[33] = 'h2e1b2138;
assign k[34] = 'h4d2c6dfc;
assign k[35] = 'h53380d13;
assign k[36] = 'h650a7354;
assign k[37] = 'h766a0abb;
assign k[38] = 'h81c2c92e;
assign k[39] = 'h92722c85;
assign k[40] = 'ha2bfe8a1;
assign k[41] = 'ha81a664b;
assign k[42] = 'hc24b8b70;
assign k[43] = 'hc76c51a3;
assign k[44] = 'hd192e819;
assign k[45] = 'hd6990624;
assign k[46] = 'hf40e3585;
assign k[47] = 'h106aa070;
assign k[48] = 'h19a4c116;
assign k[49] = 'h1e376c08;
assign k[50] = 'h2748774c;
assign k[51] = 'h34b0bcb5;
assign k[52] = 'h391c0cb3;
assign k[53] = 'h4ed8aa4a;
assign k[54] = 'h5b9cca4f;
assign k[55] = 'h682e6ff3;
assign k[56] = 'h748f82ee;
assign k[57] = 'h78a5636f;
assign k[58] = 'h84c87814;
assign k[59] = 'h8cc70208;
assign k[60] = 'h90befffa;
assign k[61] = 'ha4506ceb;
assign k[62] = 'hbef9a3f7;
assign k[63] = 'hc67178f2;

wire [31:0] hinit [8];
reg  [31:0] h [8];
reg  [31:0] hsave [8];
reg  [31:0] hadder [8];
assign hinit[0] = 'hc1059ed8;
assign hinit[1] = 'h367cd507;
assign hinit[2] = 'h3070dd17;
assign hinit[3] = 'hf70e5939;
assign hinit[4] = 'hffc00b31;
assign hinit[5] = 'h68581511;
assign hinit[6] = 'h64f98fa7;
assign hinit[7] = 'hbefa4fa4;
initial for(int i=0; i<8; i++) h[i] = '0;
initial for(int i=0; i<8; i++) hsave[i] = '0;
initial for(int i=0; i<8; i++) hadder[i] = '0;

reg [31:0] w [16];
reg [ 7:0] buff [64];
initial for(int i=0; i<16; i++) w[i] = '0;
initial for(int i=0; i<64; i++) buff[i] = '0;

enum logic [2:0] {IDLE, RUN, ADD8, ADD0, ADDLEN, DONE} status = IDLE;
reg  [60:0] cnt = '0;
reg  [ 5:0] tcnt = '0;
wire [63:0] bitlen = {cnt,3'h0};

wire       iinit;
reg        ifirst = 1'b0;
reg        ivalid = 1'b0;
reg        ilast = 1'b0;
reg [60:0] ilen  = '0;
reg [31:0] iid = '0;
reg [ 7:0] idata = '0;
reg [ 5:0] icnt = '0;
reg        minit= 1'b0;
reg        men  = 1'b0;
reg        mlast = 1'b0;
reg [31:0] mid = '0;
reg [60:0] mlen = '0;
reg [ 5:0] mcnt = '0;
reg        winit  = 1'b0;
reg        wen  = 1'b0;
reg        wlast = 1'b0;
reg [31:0] wid = '0;
reg [60:0] wlen = '0;
reg        wstart = 1'b0;
reg        wfinal = 1'b0;
reg [31:0] wadder = '0;
reg        wkinit  = 1'b0;
reg        wken = 1'b0;
reg        wklast = 1'b0;
reg [31:0] wkid = '0;
reg [60:0] wklen = '0;
reg        wkstart = 1'b0;
reg [31:0] wk = '0;

assign tready = (status==IDLE) || (status==RUN);
assign iinit  = (status==IDLE) & tvalid;

always @ (posedge clk or posedge rst)
    if(rst) begin
        status <= IDLE;
        cnt <= '0;
        tcnt <= '0;
        {ivalid, ifirst, ilast, ilen, iid, idata} <= '0;
    end else begin
        ilen <= cnt;
        case(status)
            IDLE   : begin
                if(tvalid) begin
                    status <= tlast ? ADD8 : RUN;
                    cnt <= 61'd1;
                end
                tcnt <= cnt[5:0] + 6'd1;
                ivalid <= tvalid;
                ifirst <= tvalid;
                ilast  <= 1'b0;
                iid    <= tid;
                idata  <= tdata;
            end
            RUN     : begin
                if(tvalid) begin
                    status <= tlast ? ADD8 : RUN;
                    cnt <= cnt + 61'd1;
                end
                tcnt <= cnt[5:0] + 6'd1;
                ivalid <= tvalid;
                if(tcnt==6'h3f) ifirst <= 1'b0;
                ilast  <= 1'b0;
                idata  <= tdata;
            end
            ADD8    : begin
                status <= (cnt[5:0]==6'h37) ? ADDLEN : ADD0;
                tcnt <= cnt[5:0] + 6'd1;
                ivalid <= 1'b1;
                if(tcnt==6'h3f) ifirst <= 1'b0;
                ilast  <= 1'b0;
                idata  <= 8'h80;
            end
            ADD0    : begin
                status <= (tcnt==6'h37) ? ADDLEN : ADD0;
                tcnt <= tcnt + 6'd1;
                ivalid <= 1'b1;
                if(tcnt==6'h3f) ifirst <= 1'b0;
                ilast  <= 1'b0;
                idata  <= 8'h00;
            end
            ADDLEN  : begin
                status <= (tcnt==6'h3f) ? DONE : ADDLEN;
                tcnt <= tcnt + 6'd1;
                ivalid <= 1'b1;
                if(tcnt==6'h3f) ifirst <= 1'b0;
                ilast  <= (tcnt==6'h3f);
                idata  <= bitlen[8*(7-tcnt[2:0])+:8];
            end
            default : begin
                status <= IDLE;
                cnt <= '0;
                tcnt <= '0;
                {ivalid, ifirst, ilast, ilen, idata} <= '0;
            end
        endcase
    end

always @ (posedge clk or posedge rst)
    if(rst) begin
        icnt <= '0;
        for(int i=0; i<64; i++) buff[i] <= '0;
    end else begin
        if(iinit) begin
            icnt <= '0;
        end else if(ivalid) begin
            buff[icnt] <= idata;
            icnt <= icnt + 6'd1;
        end
    end

always @ (posedge clk or posedge rst)
    if(rst) begin
        minit <= 1'b0;
        men   <= 1'b0;
        mlast <= 1'b0;
        mid   <= '0;
        mlen  <= '0;
        mcnt  <= '0;
    end else begin
        minit <= ifirst & (icnt==6'h3e);
        if(ifirst & (icnt==6'h3e)) begin
            men   <= 1'b0;
            mlast <= 1'b0;
            mcnt  <= '0;
        end else if(ivalid & (icnt==6'h3f)) begin
            men   <= 1'b1;
            mlast <= ilast;
            mid   <= iid;
            mlen  <= ilen;
            mcnt  <= '0;
        end else begin
            if(mcnt==6'h3f) begin
                men   <= 1'b0;
                mlast <= 1'b0;
            end
            if(men)
                mcnt <= mcnt + 6'd1;
        end
    end

always @ (posedge clk or posedge rst)
    if(rst) begin
        winit  <= 1'b0;
        wen    <= 1'b0;
        wlast  <= 1'b0;
        wid    <= '0;
        wlen   <= '0;
        wstart <= 1'b0;
        wfinal <= 1'b0;
        wadder <= '0;
        for(int i=0; i<16; i++) w[i] <= '0;
    end else begin
        winit  <= minit;
        wen    <= men;
        wlast  <= mlast & (mcnt==6'h3f);
        wid    <= mid;
        wlen   <= mlen;
        wstart <= men & (mcnt==6'h00);
        wfinal <= men & (mcnt==6'h3f);
        wadder <= k[mcnt];
        if(mcnt<6'd16) begin
            automatic logic [5:0] waddr0 = {mcnt[3:0],2'd0};
            automatic logic [5:0] waddr1 = {mcnt[3:0],2'd1};
            automatic logic [5:0] waddr2 = {mcnt[3:0],2'd2};
            automatic logic [5:0] waddr3 = {mcnt[3:0],2'd3};
            w[0] <= {buff[waddr0],buff[waddr1],buff[waddr2],buff[waddr3]};
        end else begin
            w[0] <= SSIG1(w[1]) + w[6] + SSIG0(w[14]) + w[15];
        end
        for(int i=1; i<16; i++) w[i] <= w[i-1];
    end

always @ (posedge clk or posedge rst)
    if(rst) begin
        wkinit <= 1'b0;
        wken <= 1'b0;
        wklast <= 1'b0;
        wkid   <= '0;
        wklen  <= '0;
        wkstart <= 1'b0;
        wk <= '0;
    end else begin
        wkinit <= winit;
        wken <= wen;
        wklast <= wlast;
        wkid   <= wid;
        wklen  <= wlen;
        wkstart <= wstart;
        wk <= w[0] + wadder;
    end

always @ (posedge clk or posedge rst)
    if(rst) begin
        for(int i=0; i<8; i++) hsave[i] <= '0;
    end else begin
        if(wkstart)
            hsave <= h;
    end

always @ (posedge clk or posedge rst)
    if(rst) begin
        for(int i=0; i<8; i++) hadder[i] <= '0;
    end else begin
        if(wfinal) begin
            hadder <= hsave;
        end else begin
            for(int i=0; i<8; i++) hadder[i] <= '0;
        end
    end

always @ (posedge clk or posedge rst)
    if(rst) begin
        for(int i=0; i<8; i++) h[i] <= '0;
    end else begin
        if(wkinit) begin
            h <= hinit;
        end else if(wken) begin
            automatic logic [31:0] t1, t2;
            t1 = h[7] + BSIG1(h[4]) + ((h[4] &  h[5]) ^ (~h[4] & h[6])) + wk;
            t2 = BSIG0(h[0]) + ((h[0] & h[1]) ^ (h[0] & h[2]) ^ (h[1] & h[2]));
            h[7] <= hadder[7] + h[6];
            h[6] <= hadder[6] + h[5];
            h[5] <= hadder[5] + h[4];
            h[4] <= hadder[4] + h[3] + t1;
            h[3] <= hadder[3] + h[2];
            h[2] <= hadder[2] + h[1];
            h[1] <= hadder[1] + h[0];
            h[0] <= hadder[0] + t1 + t2;
        end
    end

initial {ovalid,oid,olen}  =1'b0;
always @ (posedge clk or posedge rst)
    if(rst) begin
        ovalid <= 1'b0;
        oid  <= '0;
        olen <= '0;
    end else begin
        ovalid <= wklast;
        oid  <= wkid;
        olen <= wklen;
    end
assign osha = {h[0],h[1],h[2],h[3],h[4],h[5],h[6]};

endmodule
