
//--------------------------------------------------------------------------------------------------------
// Module  : sha1
// Type    : synthesizable, IP's top
// Standard: SystemVerilog 2005 (IEEE1800-2005)
//--------------------------------------------------------------------------------------------------------

module sha1(
    input  wire         rstn,
    input  wire         clk,
    input  wire         tvalid,
    output wire         tready,
    input  wire         tlast,
    input  wire [ 31:0] tid,
    input  wire [  7:0] tdata,
    output reg          ovalid,
    output reg  [ 31:0] oid,
    output reg  [ 60:0] olen,
    output wire [159:0] osha
);

function automatic logic [31:0] SL1(input [31:0] x);
    return {x[30:0], x[31]};
endfunction

function automatic logic [31:0] SL5(input [31:0] x);
    return {x[26:0], x[31:27]};
endfunction

function automatic logic [31:0] SL30(input [31:0] x);
    return {x[1:0], x[31:2]};
endfunction

wire [31:0] k [4];
assign k[ 0] = 'h5A827999;
assign k[ 1] = 'h6ED9EBA1;
assign k[ 2] = 'h8F1BBCDC;
assign k[ 3] = 'hCA62C1D6;

wire [31:0] hinit [5];
reg  [31:0] h [5];
reg  [31:0] hsave [5];
reg  [31:0] hadder [5];
assign hinit[0] = 'h67452301;
assign hinit[1] = 'hEFCDAB89;
assign hinit[2] = 'h98BADCFE;
assign hinit[3] = 'h10325476;
assign hinit[4] = 'hC3D2E1F0;
initial for(int i=0; i<5; i++) h[i] = '0;
initial for(int i=0; i<5; i++) hsave[i] = '0;
initial for(int i=0; i<5; i++) hadder[i] = '0;

reg [31:0] w [18];
reg [ 7:0] buff [64];
initial for(int i=0; i<18; i++) w[i] = '0;
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
reg [ 1:0] wtype = '0;
reg        wkinit  = 1'b0;
reg        wken = 1'b0;
reg        wklast = 1'b0;
reg [31:0] wkid = '0;
reg [60:0] wklen = '0;
reg        wkstart = 1'b0;
reg [ 1:0] wktype = '0;
reg [31:0] wk0='0, wk1='0;

assign tready = (status==IDLE) || (status==RUN);
assign iinit  = (status==IDLE) & tvalid;

always @ (posedge clk or negedge rstn)
    if(~rstn) begin
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

always @ (posedge clk or negedge rstn)
    if(~rstn) begin
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

always @ (posedge clk or negedge rstn)
    if(~rstn) begin
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
            if(mcnt==6'd39) begin
                men   <= 1'b0;
                mlast <= 1'b0;
            end
            if(men)
                mcnt <= mcnt + 6'd1;
        end
    end
            
always @ (posedge clk or negedge rstn)
    if(~rstn) begin
        winit  <= 1'b0;
        wen    <= 1'b0;
        wlast  <= 1'b0;
        wid    <= '0;
        wlen   <= '0;
        wstart <= 1'b0;
        wfinal <= 1'b0;
        wtype  <= 2'd0;
        for(int i=0; i<18; i++) w[i] <= '0;
    end else begin
        winit  <= minit;
        wen    <= men;
        wlast  <= mlast & (mcnt==6'd39);
        wid    <= mid;
        wlen   <= mlen;
        wstart <= men & (mcnt==6'd0);
        wfinal <= men & (mcnt==6'd39);
        if(mcnt<6'd10) begin
            wtype <= 2'd0;
        end else if(mcnt<6'd20) begin
            wtype <= 2'd1;
        end else if(mcnt<6'd30) begin
            wtype <= 2'd2;
        end else begin
            wtype <= 2'd3;
        end
        if(mcnt<6'd8) begin
            logic [5:0] waddr0, waddr1, waddr2, waddr3, waddr4, waddr5, waddr6, waddr7;
            waddr0 = {mcnt[2:0],3'd0};
            waddr1 = {mcnt[2:0],3'd1};
            waddr2 = {mcnt[2:0],3'd2};
            waddr3 = {mcnt[2:0],3'd3};
            waddr4 = {mcnt[2:0],3'd4};
            waddr5 = {mcnt[2:0],3'd5};
            waddr6 = {mcnt[2:0],3'd6};
            waddr7 = {mcnt[2:0],3'd7};
            w[1] <= {buff[waddr0],buff[waddr1],buff[waddr2],buff[waddr3]};
            w[0] <= {buff[waddr4],buff[waddr5],buff[waddr6],buff[waddr7]};
            for(int i=2; i<18; i++) w[i] <= w[i-2];
        end else begin
            logic [31:0] wtmp [18];
            for(int i=0; i<18; i++) wtmp[i] = w[i];
            for(int i=17; i>0; i--) wtmp[i] = wtmp[i-1];
            wtmp[0] = SL1(wtmp[16]^wtmp[14]^wtmp[8]^wtmp[3]);
            for(int i=17; i>0; i--) wtmp[i] = wtmp[i-1];
            wtmp[0] = SL1(wtmp[16]^wtmp[14]^wtmp[8]^wtmp[3]);
            for(int i=0; i<18; i++) w[i] <= wtmp[i];
        end
    end

always @ (posedge clk or negedge rstn)
    if(~rstn) begin
        wkinit <= 1'b0;
        wken <= 1'b0;
        wklast <= 1'b0;
        wkid   <= '0;
        wklen  <= '0;
        wkstart <= 1'b0;
        wktype <= '0;
        wk0 <= '0;
        wk1 <= '0;
    end else begin
        wkinit <= winit;
        wken <= wen;
        wklast <= wlast;
        wkid   <= wid;
        wklen  <= wlen;
        wkstart <= wstart;
        wktype <= wtype;
        wk0 <= w[0] + k[wtype];
        wk1 <= w[1] + k[wtype];
    end

always @ (posedge clk or negedge rstn)
    if(~rstn) begin
        for(int i=0; i<5; i++) hsave[i] <= '0;
    end else begin
        if(wkstart)
            for(int i=0; i<5; i++) hsave[i] <= h[i];
    end

always @ (posedge clk or negedge rstn)
    if(~rstn) begin
        for(int i=0; i<5; i++) hadder[i] <= '0;
    end else begin
        if(wfinal) begin
            for(int i=0; i<5; i++) hadder[i] <= hsave[i];
        end else begin
            for(int i=0; i<5; i++) hadder[i] <= '0;
        end
    end

always @ (posedge clk or negedge rstn)
    if(~rstn) begin
        for(int i=0; i<5; i++) h[i] <= '0;
    end else begin
        if(wkinit) begin
            for(int i=0; i<5; i++) h[i] <= hinit[i];
        end else if(wken) begin
            logic [31:0] ht [5];
            logic [31:0] f, t;
            for(int i=0; i<5; i++) ht[i] = h[i];
            
            case(wktype)
            2'd0    : f = (ht[1]&ht[2]) | (~ht[1]&ht[3]);
            2'd2    : f = (ht[1]&ht[2]) | (ht[1]&ht[3]) | (ht[2]&ht[3]);
            default : f = ht[1] ^ ht[2] ^ ht[3];
            endcase
            t = SL5(ht[0]) + f + ht[4] + wk1;
            ht[4] = ht[3];
            ht[3] = ht[2];
            ht[2] = SL30(ht[1]);
            ht[1] = ht[0];
            ht[0] = t;
            
            case(wktype)
            2'd0    : f = (ht[1]&ht[2]) | (~ht[1]&ht[3]);
            2'd2    : f = (ht[1]&ht[2]) | (ht[1]&ht[3]) | (ht[2]&ht[3]);
            default : f = ht[1] ^ ht[2] ^ ht[3];
            endcase
            t = SL5(ht[0]) + f + ht[4] + wk0;
            ht[4] = ht[3];
            ht[3] = ht[2];
            ht[2] = SL30(ht[1]);
            ht[1] = ht[0];
            ht[0] = t;
            
            for(int i=0; i<5; i++)
                h[i] <= hadder[i] + ht[i];
        end
    end

initial {ovalid,oid,olen}  =1'b0;
always @ (posedge clk or negedge rstn)
    if(~rstn) begin
        ovalid <= 1'b0;
        oid  <= '0;
        olen <= '0;
    end else begin
        ovalid <= wklast;
        oid  <= wkid;
        olen <= wklen;
    end
assign osha = {h[0],h[1],h[2],h[3],h[4]};

endmodule
