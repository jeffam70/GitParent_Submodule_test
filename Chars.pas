unit Chars;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, TntExtCtrls, TntGraphics, StrUtils, Math, StdCtrls, PTRegistry;

type
  TDisplayMode         = (dmStandard, dmROMBitmap, dmSymbolic);
  TOrder               = (oStandard, oSymbolic);
  TRowMetric           = (rmStartChar, rmOffset, rmLength);
  TSelectCharDirection = (scdLeft, scdRight, scdUp, scdDown);


{==============================================================================}
{=========================== TCharChartForm Type ==============================}
{==============================================================================}

  TCharChartForm = class(TForm)
    StatusPanel: TPanel;
    FontPtSizeLabel: TLabel;
    FontPtSize: TLabel;
    ControlPanel: TPanel;
    StandardOrderButton: TRadioButton;
    SymbolicOrderButton: TRadioButton;
    DecimalLabel: TLabel;
    HexadecimalLabel: TLabel;
    UnicodeLabel: TLabel;
    Decimal: TLabel;
    Hexadecimal: TLabel;
    Unicode: TLabel;
    ROMBitmapButton: TRadioButton;
    ROMLabel: TLabel;
    ROM: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GetDLGCode(var Message: TMessage); message WM_GETDLGCODE;
    procedure FormPaint(Sender: TObject);
    procedure OrderButtonClick(Sender: TObject);
    procedure OrderButtonEnter(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure FormClick(Sender: TObject);
    function  CharXPos(ID: Integer): Integer;
    function  CharYPos(ID: Integer): Integer;
    procedure PaintChart(CurCharOnly: Boolean);
    procedure CalcSymbolicRowMetrics(OffsetsOnly: Boolean);
    procedure SetChartSize;
    procedure SelectChar(Direction: TSelectCharDirection);
    function  UpdateCurChar(X, Y: Integer): Boolean;
    procedure UpdateStatus;
    function  TranslateCharID(ID: Integer; FromMode, ToMode: TDisplayMode): Integer;
    function  GetDisplayMode: Integer;
    procedure SetDisplayMode(Value: Integer);
    procedure SetFontPtSize(Value: Integer);
    function  GetFontName: String;
    procedure SetFontName(FontName: String);
    function  GetFontSize: Integer;
    procedure SetFontSize(Value: Integer);
    procedure IncFontSize;
    procedure DecFontSize;
    procedure InsertChar;
  private
    { Private declarations }
  public
    { Public declarations }
    property  DisplayMode : Integer read GetDisplayMode write SetDisplayMode;
    property  FontName : String read GetFontName write SetFontName;
    property  FontSize : Integer read GetFontSize write SetFontSize;
  end;

const
  TopCategory = 12;  {The value of the highest category ID (defined in constant block below)}

var
  CharChartForm    : TCharChartForm;
  FontBitmap       : TBitmap;          {Full font set bitmap}
  BuffBitmap       : TBitmap;          {Off-screen buffer bitmap (used to paint character set on form)}
  C01Bitmap        : TBitmap;          {Color 01 character-sized bitmap (solid color for 01 bit pairs in ROMBitmap display)}
  C10Bitmap        : TBitmap;          {Color 10 character-sized bitmap (solid color for 10 bit pairs in ROMBitmap display)}
  C11Bitmap        : TBitmap;          {Color 11 character-sized bitmap (solid color for 11 bit pairs in ROMBitmap display)}
  Scratch1Bitmap   : TBitmap;          {Temporary character-sized bitmap for use in creating ROMBitmap}
  Scratch2Bitmap   : TBitmap;          {Temporary character-sized bitmap for use in creating ROMBitmap}
  Mode             : TDisplayMode;
  XSize, YSize     : Integer;
  CurChar          : Integer;
  PrevChar         : Integer;
  MinFormWidth     : Integer;
  RowMetric        : array[low(TRowMetric)..high(TRowMetric), 0..TopCategory] of Integer;  {Row metric array}

const
  ChartBgColor = clWhite;
  ChartFtColor = clBlack;
  ChartSlColor = $E0E0E0;
  Color01 =  $B0B0B0;
  Color10 =  $606060;
  color11 =  $000000;

  {The following are used for the Symbolic Order indexes within the FontOrder array.  Each constant (A, C, I, etc) is effectively the
   index of the row that the characters will be shown on (thus, the Symbolic Order indexes within the FontOrder array must order them
   in the same order as below).}
  A = $000; {Alpha Characters (uppercase)}
  C = $100; {Alpha Characters (lowercase)}
  I = $200; {Alpha Characters (uppercase)}
  J = $300; {Alpha Characters (lowercase)}
  N = $400; {Number Characters}
  P = $500; {Punctuation Characters}
  E = $600; {Special Punctuation Characters}
  M = $700; {Math Characters}
  B = $800; {Bullet Characters}
  T = $900; {Timing Diagram Characters}
  L = $A00; {Line Drawing Characters}
  S = $B00; {Schematic Characters}   {NOTE: This is the HIGHEST CATEGORY ID.  TopCategory const (defined above) MUST be equal to this value / 256}
  V = $C00; {Bevel Characters}
  X = $F00; {Invalid Characters}     {NOTE: This one is NOT counted as a valid category}

  {Order of displayed characters.  First dimension: 0 = Standard Order, 1 = Symbolic Order}
  FontOrder : array [dmStandard..dmSymbolic,0..255] of Word =
                      ((000, 001, 002, 003, 004, 005, 006, 007, 008, 009, 010, 011, 012, 013, 014, 015,
                        016, 017, 018, 019, 020, 021, 022, 023, 024, 025, 026, 027, 028, 029, 030, 031,
                        032, 033, 034, 035, 036, 037, 038, 039, 040, 041, 042, 043, 044, 045, 046, 047,
                        048, 049, 050, 051, 052, 053, 054, 055, 056, 057, 058, 059, 060, 061, 062, 063,
                        064, 065, 066, 067, 068, 069, 070, 071, 072, 073, 074, 075, 076, 077, 078, 079,
                        080, 081, 082, 083, 084, 085, 086, 087, 088, 089, 090, 091, 092, 093, 094, 095,
                        096, 097, 098, 099, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111,
                        112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127,
                        128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143,
                        144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159,
                        160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175,
                        176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191,
                        192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207,
                        208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223,
                        224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239,
                        240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255),

                        (000, 001, 002, 003, 004, 005, 006, 007, 008, 009, 010, 011, 012, 013, 014, 015,
                        016, 017, 018, 019, 020, 021, 022, 023, 024, 025, 026, 027, 028, 029, 030, 031,
                        032, 033, 034, 035, 036, 037, 038, 039, 040, 041, 042, 043, 044, 045, 046, 047,
                        048, 049, 050, 051, 052, 053, 054, 055, 056, 057, 058, 059, 060, 061, 062, 063,
                        064, 065, 066, 067, 068, 069, 070, 071, 072, 073, 074, 075, 076, 077, 078, 079,
                        080, 081, 082, 083, 084, 085, 086, 087, 088, 089, 090, 091, 092, 093, 094, 095,
                        096, 097, 098, 099, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111,
                        112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127,
                        128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143,
                        144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159,
                        160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175,
                        176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191,
                        192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207,
                        208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223,
                        224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239,
                        240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255),

                       (A+065, A+066, A+067, A+068, A+069, A+070, A+071, A+072, A+073, A+074, A+075, A+076, A+077, A+078, A+079, A+080,
                        A+081, A+082, A+083, A+084, A+085, A+086, A+087, A+088, A+089, A+090, C+097, C+098, C+099, C+100, C+101, C+102,
                        C+103, C+104, C+105, C+106, C+107, C+108, C+109, C+110, C+111, C+112, C+113, C+114, C+115, C+116, C+117, C+118,
                        C+119, C+120, C+121, C+122, I+192, I+193, I+194, I+195, I+196, I+197, I+198, I+199, I+200, I+201, I+202, I+203,
                        I+204, I+205, I+206, I+207, I+208, I+209, I+210, I+211, I+212, I+213, I+214, I+216, I+217, I+218, I+219, I+220,
                        I+221, I+222, I+223, J+224, J+225, J+226, J+227, J+228, J+229, J+230, J+231, J+232, J+233, J+234, J+235, J+236,
                        J+237, J+238, J+239, J+240, J+241, J+242, J+243, J+244, J+245, J+246, J+248, J+249, J+250, J+251, J+252, J+253,
                        J+254, N+048, N+049, N+050, N+051, N+052, N+053, N+054, N+055, N+056, N+057, P+032, P+095, P+046, P+044, P+058,
                        P+059, P+039, P+034, P+033, P+161, P+063, P+191, E+060, E+062, E+040, E+041, E+123, E+125, E+091, E+093, E+047,
                        E+092, E+124, E+094, E+035, E+037, E+038, E+064, E+036, E+163, E+164, E+165, E+176, E+096, E+126, E+042, M+177,
                        M+043, M+045, M+215, M+247, M+061, M+020, M+021, M+022, M+185, M+178, M+179, M+016, M+181, M+017, M+018, M+019,
                        M+255, B+002, B+003, B+004, B+005, B+006, B+007, B+014, B+015, T+128, T+129, T+130, T+131, T+132, T+133, T+134,
                        T+135, T+136, T+137, T+138, T+139, T+140, T+141, T+142, T+143, L+144, L+145, L+146, L+147, L+148, L+149, L+150,
                        L+151, L+152, L+153, L+154, L+155, L+156, L+157, L+158, L+159, S+160, S+162, S+175, S+180, S+186, S+187, S+169,
                        S+170, S+023, S+024, S+188, S+189, S+190, S+182, S+183, S+184, S+171, S+172, S+173, S+174, S+127, S+166, S+167,
                        S+168, S+028, S+029, S+030, S+031, S+025, S+026, S+027, V+000, V+001, V+008, V+009, V+010, V+011, V+012, V+013));

  {Character values (in ASCII order)}
  FontMap : array[0..255] of Word = ($F000, $F001, $2190, $2192, $2191, $2193, $25C0, $25B6,
                                     $F008, $F009, $F00A, $F00B, $F00C, $F00D, $2023, $2022,
                                     $0394, $03C0, $03A3, $03A9, $2248, $221A, $F016, $F017,
                                     $F018, $F019, $F01A, $F01B, $F01C, $F01D, $F01E, $F01F,
                                     $0020, $0021, $0022, $0023, $0024, $0025, $0026, $0027,
                                     $0028, $0029, $002A, $002B, $002C, $002D, $002E, $002F,
                                     $0030, $0031, $0032, $0033, $0034, $0035, $0036, $0037,
                                     $0038, $0039, $003A, $003B, $003C, $003D, $003E, $003F,
                                     $0040, $0041, $0042, $0043, $0044, $0045, $0046, $0047,
                                     $0048, $0049, $004A, $004B, $004C, $004D, $004E, $004F,
                                     $0050, $0051, $0052, $0053, $0054, $0055, $0056, $0057,
                                     $0058, $0059, $005A, $005B, $005C, $005D, $005E, $005F,
                                     $0060, $0061, $0062, $0063, $0064, $0065, $0066, $0067,
                                     $0068, $0069, $006A, $006B, $006C, $006D, $006E, $006F,
                                     $0070, $0071, $0072, $0073, $0074, $0075, $0076, $0077,
                                     $0078, $0079, $007A, $007B, $007C, $007D, $007E, $F07F,
                                     $F080, $F081, $F082, $F083, $F084, $F085, $F086, $F087,
                                     $F088, $F089, $F08A, $F08B, $F08C, $F08D, $F08E, $F08F,
                                     $2500, $2502, $253C, $254B, $2524, $251C, $2534, $252C,
                                     $252B, $2523, $253B, $2533, $2518, $2514, $2510, $250C,
                                     $F0A0, $00A1, $F0A2, $00A3, $20AC, $00A5, $F0A6, $F0A7,
                                     $F0A8, $F0A9, $F0AA, $F0AB, $F0AC, $F0AD, $F0AE, $F0AF,
                                     $00B0, $00B1, $00B2, $00B3, $F0B4, $00B5, $F0B6, $F0B7,
                                     $F0B8, $00B9, $F0BA, $F0BB, $F0BC, $F0BD, $F0BE, $00BF,
                                     $00C0, $00C1, $00C2, $00C3, $00C4, $00C5, $00C6, $00C7,
                                     $00C8, $00C9, $00CA, $00CB, $00CC, $00CD, $00CE, $00CF,
                                     $00D0, $00D1, $00D2, $00D3, $00D4, $00D5, $00D6, $00D7,
                                     $00D8, $00D9, $00DA, $00DB, $00DC, $00DD, $00DE, $00DF,
                                     $00E0, $00E1, $00E2, $00E3, $00E4, $00E5, $00E6, $00E7,
                                     $00E8, $00E9, $00EA, $00EB, $00EC, $00ED, $00EE, $00EF,
                                     $00F0, $00F1, $00F2, $00F3, $00F4, $00F5, $00F6, $00F7,
                                     $00F8, $00F9, $00FA, $00FB, $00FC, $00FD, $00FE, $221E);

  {Character descriptions (in ASCII order)}
  FontDesc : array[0..255] of String = ('Bevel: Left Corners, Focused (Run-Time Only)',
                                        'Bevel: Left Corners (Run-Time Only)',
                                        'Bullet: Left Arrow',
                                        'Bullet: Right Arrow',
                                        'Bullet: Up Arrow',
                                        'Bullet: Down Arrow',
                                        'Bullet: Left',
                                        'Bullet: Right',
                                        'Bevel: Right Corners, Focused (Run-Time Only)',
                                        'Bevel: Right Corners (Run-Time Only)',
                                        'Bevel: Left/Right Sides (Run-Time Only)',
                                        'Bevel: Left/Right Sides (Run-Time Only)',
                                        'Bevel: Top/Bottom Sides, Over/Underlined (Run-Time Only)',
                                        'Bevel: Top/Bottom Sides (Run-Time Only)',
                                        'Bullet: Rectangle',
                                        'Bullet',
                                        'Math: Delta',
                                        'Math: Pi',
                                        'Math: Sigma',
                                        'Math: Omega',
                                        'Math: Approximate Equal',
                                        'Math: Radical',
                                        'Math: Negative One Superior',
                                        'Schematic: Power',
                                        'Schematic: Ground',
                                        'Schematic: FET N Gate (Part 1 of 2)',
                                        'Schematic: FET P Gate (Part 1 of 2)',
                                        'Schematic: FET Source Drain (Part 2 of 2)',
                                        'Schematic: NPN/PNP Base (Part 1 of 2)',
                                        'Schematic: NPN/PNP Base, Photo (Part 1 of 2)',
                                        'Schematic: NPN Emitter Collector (Part 2 of 2)',
                                        'Schematic: PNP Emitter Collector (Part 2 of 2)',
                                        'Punctuation: Space',
                                        'Punctuation: Exclamation',
                                        'Punctuation: Quote',
                                        'Special Punctuation: Number',
                                        'Special Punctuation: Dollar',
                                        'Special Punctuation: Percent',
                                        'Special Punctuation: Ampersand',
                                        'Punctuation: Apostrophe',
                                        'Special Punctuation: Left Parenthesis',
                                        'Special Punctuation: Right Parenthesis',
                                        'Special Punctuation: Asterisk',
                                        'Math: Plus',
                                        'Punctuation: Comma',
                                        'Math: Minus',
                                        'Punctuation: Period',
                                        'Special Punctuation: Forward Slash',
                                        'Number: Zero',
                                        'Number: One',
                                        'Number: Two',
                                        'Number: Three',
                                        'Number: Four',
                                        'Number: Five',
                                        'Number: Six',
                                        'Number: Seven',
                                        'Number: Eight',
                                        'Number: Nine',
                                        'Punctuation: Colon',
                                        'Punctuation: Semicolon',
                                        'Special Punctuation: Less Than',
                                        'Math: Equal',
                                        'Special Punctuation: Greater Than',
                                        'Punctuation: Question',
                                        'Special Punctuation: At',
                                        'Alpha: A',
                                        'Alpha: B',
                                        'Alpha: C',
                                        'Alpha: D',
                                        'Alpha: E',
                                        'Alpha: F',
                                        'Alpha: G',
                                        'Alpha: H',
                                        'Alpha: I',
                                        'Alpha: J',
                                        'Alpha: K',
                                        'Alpha: L',
                                        'Alpha: M',
                                        'Alpha: N',
                                        'Alpha: O',
                                        'Alpha: P',
                                        'Alpha: Q',
                                        'Alpha: R',
                                        'Alpha: S',
                                        'Alpha: T',
                                        'Alpha: U',
                                        'Alpha: V',
                                        'Alpha: W',
                                        'Alpha: X',
                                        'Alpha: Y',
                                        'Alpha: Z',
                                        'Special Punctuation: Left Square Bracket',
                                        'Special Punctuation: Backward Slash',
                                        'Special Punctuation: Right Square Bracket',
                                        'Special Punctuation: Punctuation: Circumflex',
                                        'Punctuation: Underscore',
                                        'Special Punctuation: Grave',
                                        'Alpha: a',
                                        'Alpha: b',
                                        'Alpha: c',
                                        'Alpha: d',
                                        'Alpha: e',
                                        'Alpha: f',
                                        'Alpha: g',
                                        'Alpha: h',
                                        'Alpha: i',
                                        'Alpha: j',
                                        'Alpha: k',
                                        'Alpha: l',
                                        'Alpha: m',
                                        'Alpha: n',
                                        'Alpha: o',
                                        'Alpha: p',
                                        'Alpha: q',
                                        'Alpha: r',
                                        'Alpha: s',
                                        'Alpha: t',
                                        'Alpha: u',
                                        'Alpha: v',
                                        'Alpha: w',
                                        'Alpha: x',
                                        'Alpha: y',
                                        'Alpha: z',
                                        'Special Punctuation: Left Curly Brace',
                                        'Special Punctuation: Pipe',
                                        'Special Punctuation: Right Curly Brace',
                                        'Special Punctuation: Tilde',
                                        'Schematic: Crystal / Resonator',
                                        'Timing: Dual X',
                                        'Timing: Low',
                                        'Timing: Low to High',
                                        'Timing: Low to Dual',
                                        'Timing: Low to Tristate',
                                        'Timing: High to Low',
                                        'Timing: High',
                                        'Timing: High to Dual',
                                        'Timing: High to Tristate',
                                        'Timing: Dual to Low',
                                        'Timing: Dual to High',
                                        'Timing: Dual',
                                        'Timing: Dual to Tristate',
                                        'Timing: Tristate to Low',
                                        'Timing: Tristate to High',
                                        'Timing: Tristate to Dual',
                                        'Line: Horizontal',
                                        'Line: Vertical',
                                        'Line: Vertical / Horizontal',
                                        'Line: Vertical / Horizontal Intersection',
                                        'Line: Left T',
                                        'Line: Right T',
                                        'Line: Up T',
                                        'Line: Down T',
                                        'Line: Left T Intersection',
                                        'Line: Right T Intersection',
                                        'Line: Up T Intersection',
                                        'Line: Down T Intersection',
                                        'Line: Lower Right Corner',
                                        'Line: Lower Left Corner',
                                        'Line: Upper Right Corner',
                                        'Line: Upper Left Corner',
                                        'Schematic: Up Arrow',
                                        'Punctuation: Exclamation Down',
                                        'Schematic: Down Arrow',
                                        'Special Punctuation: Sterling',
                                        'Special Punctuation: Euro',
                                        'Special Punctuation: Yen',
                                        'Schematic: Diode Anode (Part 1 of 2)',
                                        'Schematic: Diode Cathode (Part 2 of 2)',
                                        'Schematic: Diode Cathode, Photo (Part 2 of 2)',
                                        'Schematic: Left Input Node',
                                        'Schematic: Right Input Node',
                                        'Schematic: Horizontal Capacitor',
                                        'Schematic: Vertical Capacitor (Part 1 of 3)',
                                        'Schematic: Vertical Capacitor (Part 2 of 3)',
                                        'Schematic: Vertical Capacitor (Part 3 of 3)',
                                        'Schematic: Left Node',
                                        'Special Punctuation: Degree',
                                        'Math: Plus / Minus',
                                        'Math: Two Superior',
                                        'Math: Three Superior',
                                        'Schematic: Right Node',
                                        'Math: Mu',
                                        'Schematic: Vertical Inductor',
                                        'Schematic: Horizontal Inductor (Part 1 of 2)',
                                        'Schematic: Horizontal Inductor (Part 2 of 2)',
                                        'Math: One Superior',
                                        'Schematic: Left Output Node',
                                        'Schematic: Right Output Node',
                                        'Schematic: Vertical Resistor',
                                        'Schematic: Horizontal Resistor (Part 1 of 2)',
                                        'Schematic: Horizontal Resistor (Part 2 of 2)',
                                        'Punctuation: Question Down',
                                        'Alpha: A Grave',
                                        'Alpha: A Acute',
                                        'Alpha: A Circumflex',
                                        'Alpha: A Tilde',
                                        'Alpha: A Dieresis',
                                        'Alpha: A Ring',
                                        'Alpha: AE',
                                        'Alpha: C Cedilla',
                                        'Alpha: E Grave',
                                        'Alpha: E Acute',
                                        'Alpha: E Circumflex',
                                        'Alpha: E Dieresis',
                                        'Alpha: I Grave',
                                        'Alpha: I Acute',
                                        'Alpha: I Circumflex',
                                        'Alpha: I Dieresis',
                                        'Alpha: Eth',
                                        'Alpha: N Tilde',
                                        'Alpha: O Grave',
                                        'Alpha: O Acute',
                                        'Alpha: O Circumflex',
                                        'Alpha: O Tilde',
                                        'Alpha: O Dieresis',
                                        'Math: Multiply',
                                        'Alpha: O Slash',
                                        'Alpha: U Grave',
                                        'Alpha: U Acute',
                                        'Alpha: U Circumflex',
                                        'Alpha: U Dieresis',
                                        'Alpha: Y Acute',
                                        'Alpha: Thorn',
                                        'Alpha: German Double S',
                                        'Alpha: a Grave',
                                        'Alpha: a Acute',
                                        'Alpha: a Circumflex',
                                        'Alpha: a Tilde',
                                        'Alpha: a Dieresis',
                                        'Alpha: a Ring',
                                        'Alpha: ae',
                                        'Alpha: c Cedilla',
                                        'Alpha: e Grave',
                                        'Alpha: e Acute',
                                        'Alpha: e Circumflex',
                                        'Alpha: e Dieresis',
                                        'Alpha: i Grave',
                                        'Alpha: i Acute',
                                        'Alpha: i Circumflex',
                                        'Alpha: i Dieresis',
                                        'Alpha: eth',
                                        'Alpha: n Tilde',
                                        'Alpha: o Grave',
                                        'Alpha: o Acute',
                                        'Alpha: o Circumflex',
                                        'Alpha: o Tilde',
                                        'Alpha: o Dieresis',
                                        'Math: Divide',
                                        'Alpha: o Slash',
                                        'Alpha: u Grave',
                                        'Alpha: u Acute',
                                        'Alpha: u Circumflex',
                                        'Alpha: u Dieresis',
                                        'Alpha: y Acute',
                                        'Alpha: thorn',
                                        'Math: Infinity');

implementation

Uses
  Global;

{$R *.dfm}

{##############################################################################}
{############################### Global Routines ##############################}
{##############################################################################}

function StrToInt(S: String): Integer;
{Convert String to Integer. If integer value is preceeded by non-digit data, searches until it finds the first valid
digit, then converts until the next invalid digit or end of string.}
var
  Value : Integer;
  Idx   : Integer;
begin
  while (length(S) > 0) and not (S[1] in ['0'..'9']) do S := rightstr(S, length(S)-1);
  Val(S, Value, Idx);
  StrToInt := Value;
end;

{------------------------------------------------------------------------------}

function IntToFixedStr(Value: Integer; Characters: Integer): String;
{Return Value as a string of size Characters (left padded with 0 if necessary)}
begin
  Result := rightstr(inttostr(Value), Characters);
  Result := stringofchar('0', Characters-length(Result))+Result;
end;

{##############################################################################}
{########################### TCharChartForm Routines ##########################}
{##############################################################################}

{------------------------------------------------------------------------------}
{------------------------------ Event Procedures ------------------------------}
{------------------------------------------------------------------------------}

procedure TCharChartForm.FormCreate(Sender: TObject);
{Initialize settings}
begin
  CharChartForm.DoubleBuffered := True;
  ControlPanel.DoubleBuffered := True;
end;

{------------------------------------------------------------------------------}

procedure TCharChartForm.FormShow(Sender: TObject);
{Initialize view settings}
begin
  CalcSymbolicRowMetrics(False);
  SetChartSize;
  UpdateStatus;
  MinFormWidth := Unicode.Left + Unicode.Width - FontPtSizeLabel.Left + 23;
  {Make sure form is at reasonably displayable coordinates}
  EnsureWindowDisplayable(CharChartForm);
end;

{------------------------------------------------------------------------------}

procedure TCharChartForm.GetDLGCode(var Message: TMessage);
{Tell Windows we want to process Tab key presses (we won't, but this way focus is not moved to any control)}
begin
  Message.Result := DLGC_WANTTAB;
end;

{------------------------------------------------------------------------------}

procedure TCharChartform.FormPaint(Sender: TObject);
{Paint form's chart}
begin
  PaintChart(False);
end;

{------------------------------------------------------------------------------}

procedure TCharChartForm.OrderButtonClick(Sender: TObject);
{Change order of character display}
begin
  CurChar := TranslateCharID(CurChar, Mode, TDisplayMode(TControl(Sender).Tag));
  SetDisplayMode(TControl(Sender).Tag);
  ActiveControl := nil;  {Make sure no control (other than the form itself) remains active}
end;

{------------------------------------------------------------------------------}

procedure TCharChartForm.OrderButtonEnter(Sender: TObject);
{Prevent focus from staying on radio buttons}
begin
  if TRadioButton(Sender).Checked then ActiveControl := nil;
end;

{------------------------------------------------------------------------------}

procedure TCharChartForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
{Process arrow key events}
begin
  case Key of
    VK_Left  : SelectChar(scdLeft);
    VK_Right : SelectChar(scdRight);
    VK_Up    : SelectChar(scdUp);
    VK_Down  : SelectChar(scdDown);
  end;
  UpdateStatus;
end;

{------------------------------------------------------------------------------}

procedure TCharChartForm.FormKeyPress(Sender: TObject; var Key: Char);
{Insert the current character into the active edit}
begin
  if Key = char(13) then InsertChar;
end;

{------------------------------------------------------------------------------}

procedure TCharChartForm.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
{Update current character (under mouse) and status display}
begin
  UpdateCurChar(X, Y);
  UpdateStatus;
end;

{------------------------------------------------------------------------------}

procedure TCharChartForm.FormMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
{Change font size}
var
  Idx : Integer;
begin
  Idx := WheelDelta div WHEEL_DELTA;
  if (Shift = [ssCtrl]) or (Shift = []) then
    begin {Ctrl+MouseWheel = change font size}
    while Idx <> 0 do
      begin
      if Idx > 0 then IncFontSize else DecFontSize;
      Idx := Idx - 1 + 2*ord(Idx < 0);
      end;
    Repaint;
    Handled := True;
    end;
end;

{------------------------------------------------------------------------------}

procedure TCharChartForm.FormClick(Sender: TObject);
var
  Pos : TPoint;
begin
  Pos := ScreenToClient(Mouse.CursorPos);
  if UpdateCurChar(Pos.X, Pos.Y) then InsertChar else messagebeep(MB_OK);
end;

{------------------------------------------------------------------------------}
{---------------------------- Non-Event Procedures ----------------------------}
{------------------------------------------------------------------------------}

function TCharChartForm.CharXPos(ID: Integer): Integer;
{Return X position of ID character}
begin
  case Mode of
    dmStandard  : Result := (CharChartForm.ClientWidth div 2) - (((XSize+1) * 32) div 2) + (XSize+1) * (ID mod 32) + 1;
    dmROMBitmap : Result := (CharChartForm.ClientWidth div 2) - (((XSize+1) * 16) div 2) + (XSize+1) * ((ID mod 32) div 2) + 1;
    dmSymbolic  : Result := RowMetric[rmOffset, FontOrder[dmSymbolic, ID] shr 8] + (XSize+1) * ((ID - RowMetric[rmStartChar, FontOrder[dmSymbolic, ID] shr 8]) mod 32) + 1;
  end;
end;

{------------------------------------------------------------------------------}

function TCharChartForm.CharYPos(ID: Integer): Integer;
{Return Y position of ID character}
begin
  case Mode of
    dmStandard  : Result := (YSize+1) * (ID div 32) + 1;
    dmROMBitmap : Result := (YSize+2) * (ID div 32) + 1;
    dmSymbolic  : Result := (YSize+1) * (FontOrder[dmSymbolic, ID] shr 8) + 1;
  end;
end;

{------------------------------------------------------------------------------}

procedure TCharChartForm.PaintChart(CurCharOnly: Boolean);
{Paint the character chart and highlight the currently selected character}
var
  Idx        : Integer;

    {-----------------------}

    procedure PaintChar(ID: Integer);
    {Paint ID character on bitmap}
    begin
      if (ID < 0) or (ID > 255) or (FontOrder[Mode, ID] >= X) then exit; {Exit if invalid character}
      BuffBitmap.Canvas.Pen.Color := ChartFtColor;
      if Mode <> dmROMBitmap then
        begin {Standard or Symbolic display modes}
        if ID <> CurChar then BuffBitmap.Canvas.Brush.Color := ChartBgColor else BuffBitmap.Canvas.Brush.Color := ChartSlColor;
        BuffBitmap.Canvas.Rectangle(rect(CharXPos(ID)-1, CharYPos(ID)-1, CharXPos(ID)+XSize+1, CharYPos(ID)+YSize+1));
        bitblt(BuffBitmap.Canvas.Handle, CharXPos(ID), CharYPos(ID), XSize, YSize, FontBitmap.Canvas.Handle, XSize*((FontOrder[Mode, ID] and $FF) mod 32), YSize*((FontOrder[Mode, ID] and $FF) div 32), srcand);
        end
      else
        begin {ROM Bitmap display mode}
        {Top and bottom regions of character}
        if ID and $FE <> CurChar then BuffBitmap.Canvas.Brush.Color := ChartBgColor else BuffBitmap.Canvas.Brush.Color := ChartSlColor;
        BuffBitmap.Canvas.Rectangle(rect(CharXPos(ID)-1, CharYPos(ID)-1, CharXPos(ID)+XSize+1, CharYPos(ID)+(YSize div 2)+1));
        if ID and $FE + 1 <> CurChar then BuffBitmap.Canvas.Brush.Color := ChartBgColor else BuffBitmap.Canvas.Brush.Color := ChartSlColor;
        BuffBitmap.Canvas.Rectangle(rect(CharXPos(ID)-1, CharYPos(ID)+(YSize div 2), CharXPos(ID)+XSize+1, CharYPos(ID)+YSize+2));
        {Copy character 0 to Scratch1}
        bitblt(Scratch1Bitmap.Canvas.Handle, 0, 0, XSize, YSize, FontBitmap.Canvas.Handle, XSize*((FontOrder[Mode, ID and $FE] and $FF) mod 32), YSize*((FontOrder[Mode, ID] and $FF) div 32), srccopy);
        {OR character 1 to Scratch1 (creates intersection)}
        bitblt(Scratch1Bitmap.Canvas.Handle, 0, 0, XSize, YSize, FontBitmap.Canvas.Handle, XSize*((FontOrder[Mode, ID and $FE + 1] and $FF) mod 32), YSize*((FontOrder[Mode, ID] and $FF) div 32), srcpaint);

        {Copy character 0 to Scratch2}
        bitblt(Scratch2Bitmap.Canvas.Handle, 0, 0, XSize, YSize, FontBitmap.Canvas.Handle, XSize*((FontOrder[Mode, ID and $FE] and $FF) mod 32), YSize*((FontOrder[Mode, ID] and $FF) div 32), srccopy);
        {OR inverted Scratch1 to Scratch2 (creates char0 no intersection), color C01}
        bitblt(Scratch2Bitmap.Canvas.Handle, 0, 0, XSize, YSize, Scratch1Bitmap.Canvas.Handle, 0, 0, mergepaint);
        bitblt(Scratch2Bitmap.Canvas.Handle, 0, 0, XSize, YSize, C01Bitmap.Canvas.Handle, 0, 0, srcpaint);
        {Copy C01 image to both top and bottom character cells of Buffer Bitmap}
        bitblt(BuffBitmap.Canvas.Handle, CharXPos(ID), CharYPos(ID), XSize, (YSize div 2), Scratch2Bitmap.Canvas.Handle, 0, 0, srcand);
        bitblt(BuffBitmap.Canvas.Handle, CharXPos(ID), CharYPos(ID)+(YSize div 2)+1, XSize, YSize-(YSize div 2), Scratch2Bitmap.Canvas.Handle, 0, YSize-(YSize div 2), srcand);

        {Copy character 1 to Scratch2}
        bitblt(Scratch2Bitmap.Canvas.Handle, 0, 0, XSize, YSize, FontBitmap.Canvas.Handle, XSize*((FontOrder[Mode, ID and $FE + 1] and $FF) mod 32), YSize*((FontOrder[Mode, ID] and $FF) div 32), srccopy);
        {OR inverted Scratch1 to Scratch2 (creates char1 no intersection), color C10}
        bitblt(Scratch2Bitmap.Canvas.Handle, 0, 0, XSize, YSize, Scratch1Bitmap.Canvas.Handle, 0, 0, mergepaint);
        bitblt(Scratch2Bitmap.Canvas.Handle, 0, 0, XSize, YSize, C10Bitmap.Canvas.Handle, 0, 0, srcpaint);
        {Copy C10 image to both top and bottom character cells of Buffer Bitmap}
        bitblt(BuffBitmap.Canvas.Handle, CharXPos(ID), CharYPos(ID), XSize, (YSize div 2), Scratch2Bitmap.Canvas.Handle, 0, 0, srcand);
        bitblt(BuffBitmap.Canvas.Handle, CharXPos(ID), CharYPos(ID)+(YSize div 2)+1, XSize, YSize-(YSize div 2), Scratch2Bitmap.Canvas.Handle, 0, YSize-(YSize div 2), srcand);

        {Set Scratch1 to color C11}
        bitblt(Scratch1Bitmap.Canvas.Handle, 0, 0, XSize, YSize, C11Bitmap.Canvas.Handle, 0, 0, srcpaint);
        {Copy C11 image to both top and bottom character cells of Buffer Bitmap}
        bitblt(BuffBitmap.Canvas.Handle, CharXPos(ID), CharYPos(ID), XSize, (YSize div 2), Scratch1Bitmap.Canvas.Handle, 0, 0, srcand);
        bitblt(BuffBitmap.Canvas.Handle, CharXPos(ID), CharYPos(ID)+(YSize div 2)+1, XSize, YSize-(YSize div 2), Scratch1Bitmap.Canvas.Handle, 0, YSize-(YSize div 2), srcand);
        end;
    end;

      {-----------------------}

begin
  if not CurCharOnly then
    begin {Need full redraw...}
    BuffBitmap.Width := CharChartForm.ClientWidth;
    BuffBitmap.Height := CharChartForm.ClientHeight-ControlPanel.Height-StatusPanel.Height;
    BuffBitmap.Canvas.Brush.Color := clWhite-$111111;
    BuffBitmap.Canvas.FillRect(Rect(0, 0, BuffBitmap.Width, BuffBitmap.Height));
    for Idx := 0 to 255 do PaintChar(Idx);                                                                   {Paint all characters}
    end
  else
    begin
    PaintChar(PrevChar);                                                                                     {Paint previously selected character}
    PaintChar(CurChar);                                                                                      {Paint selected character}
    end;
  PrevChar := CurChar;
  bitblt(CharChartForm.Canvas.Handle, 0, ControlPanel.Height, CharChartForm.ClientWidth, CharChartForm.ClientHeight, BuffBitmap.Canvas.Handle, 0, 0, srccopy);
end;

{------------------------------------------------------------------------------}

procedure TCharChartForm.CalcSymbolicRowMetrics(OffsetsOnly: Boolean);
{Determine row metrics (starting character, x offset and length) for the Symbolic Order view}
var
  Idx       : Integer;
  RowIdx    : Integer;
begin
  if not OffsetsOnly then
    begin {Not offsets only, so calc all metrics}
    {Clear metrics}
    for Idx := low(RowMetric[rmStartChar]) to high(RowMetric[rmStartChar]) do
      begin
      RowMetric[rmStartChar, Idx] := -1;
      RowMetric[rmOffset, Idx] := 0;
      RowMetric[rmLength, Idx] := 0;
      end;
    {Get Start Chars and Row lengths}
    for Idx := 0 to 255 do
      if FontOrder[dmSymbolic, Idx] < X then
        begin
        RowIdx := FontOrder[dmSymbolic, Idx] shr 8;
        if RowMetric[rmStartChar, RowIdx] = -1 then RowMetric[rmStartChar, RowIdx] := Idx; {Start Char}
        inc(RowMetric[rmLength, RowIdx]);                                                  {Row Length (# of chars)}
        end;
    end;
  {Calculate row offsets}
  for Idx := low(RowMetric[rmStartChar]) to high(RowMetric[rmStartChar]) do RowMetric[rmOffset, Idx] := (CharChartForm.ClientWidth div 2) - ((XSize+1) * RowMetric[rmLength, Idx] + 1) div 2;
end;

{------------------------------------------------------------------------------}

procedure TCharChartForm.SetChartSize;
{Set chart and chart form size based on current font size}
var
  BlockWidth : Integer;
  Offset     : Integer;
  CenterPos  : Integer;
  NewWidth   : Integer;
begin
  CenterPos := CharChartForm.Left + (CharChartForm.Width div 2);
  {Set form width (must be done after calculating X and Y Size (in SetFontSize) and before CalcSymbolicRowMetrics)}
  NewWidth := Max((XSize+1) * 16 * (1+ord(Mode <> dmROMBitmap)) - 1 + GetSystemMetrics(SM_CXSIZEFRAME) * 2, MinFormWidth);
  CharChartForm.SetBounds(CenterPos - (NewWidth div 2), CharChartForm.Top, NewWidth, CharChartForm.Height);
  EnsureWindowDisplayable(CharChartForm);
  {Calculate X and Y sizes of current font size and then row offsets for the Symbolic Order view}
  CalcSymbolicRowMetrics(True);
  {Set form height}
  CharChartForm.ClientHeight := (YSize+1+ord(Mode = dmROMBitmap)) * max(8, (TopCategory+1)*ord(Mode = dmSymbolic)) + 1 + ControlPanel.Height + StatusPanel.Height;
  {Center Control Panel controls}
  BlockWidth := SymbolicOrderButton.Left + SymbolicOrderButton.Width - StandardOrderButton.Left;
  Offset := (ControlPanel.Width div 2) - (BlockWidth div 2) - StandardOrderButton.Left;
  StandardOrderButton.Left := StandardOrderButton.Left + Offset;
  ROMBitmapButton.Left := ROMBitmapButton.Left + Offset;
  SymbolicOrderButton.Left := SymbolicOrderButton.Left + Offset;
  {Center Status Panel text}
  if Mode <> dmROMBitmap then BlockWidth := Unicode.Left + Unicode.Width - FontPtSizeLabel.Left else BlockWidth := ROM.Left + ROM.Width - FontPtSizeLabel.Left;
  Offset := (StatusPanel.Width div 2) - (BlockWidth div 2) - FontPtSizeLabel.Left;
  DecimalLabel.Visible := Mode <> dmROMBitmap;
  Decimal.Visible := Mode <> dmROMBitmap;
  HexadecimalLabel.Visible := Mode <> dmROMBitmap;
  Hexadecimal.Visible := Mode <> dmROMBitmap;
  UnicodeLabel.Visible := Mode <> dmROMBitmap;
  Unicode.Visible := Mode <> dmROMBitmap;
  ROMLabel.Visible := Mode = dmROMBitmap;
  ROM.Visible := Mode = dmROMBitmap;
  FontPtSizeLabel.Left := FontPtSizeLabel.Left + Offset;
  FontPtSize.Left := FontPtSize.Left + Offset;
  DecimalLabel.Left := DecimalLabel.Left + Offset;
  Decimal.Left := Decimal.Left + Offset;
  HexadecimalLabel.Left := HexadecimalLabel.Left + Offset;
  Hexadecimal.Left := Hexadecimal.Left + Offset;
  UnicodeLabel.Left := UnicodeLabel.Left + Offset;
  Unicode.Left := Unicode.Left + Offset;
  ROMLabel.Left := ROMLabel.Left + Offset;
  ROM.Left := ROM.Left + Offset;
end;

{------------------------------------------------------------------------------}

procedure TCharChartForm.SelectChar(Direction: TSelectCharDirection);
{Select character relative to current character in Direction and Units}
begin
  case Direction of
    scdLeft  : CurChar := max(0, CurChar - 1 - ord(Mode = dmROMBitmap));
    scdRight : CurChar := min(255, CurChar + 1 + ord(Mode = dmROMBitmap));
    scdUp    : begin
               case Mode of
                 dmStandard  : CurChar := max(0, CurChar - 32);
                 dmROMBitmap : CurChar := max(0, CurChar - 31 + 30*(CurChar and 1));
                 dmSymbolic  : UpdateCurChar(CharXPos(CurChar), CharYPos(CurChar)+ControlPanel.Height-YSize);
               end;
               end;
    scdDown  : begin
               case Mode of
                 dmStandard  : CurChar := min(255, CurChar + 32);
                 dmROMBitmap : CurChar := min(255, CurChar + 31 - 30*((CurChar and 1) xor 1));
                 dmSymbolic  : UpdateCurChar(CharXPos(CurChar), CharYPos(CurChar)+ControlPanel.Height+YSize);
               end;
               end;
  end;
end;

{------------------------------------------------------------------------------}

function TCharChartForm.UpdateCurChar(X, Y: Integer): Boolean;
{Update current character (CurChar) value based on X/Y coordinate.  Returns True if X/Y corresponds to a valid character, False otherwise.}
begin
  Result := False;
  {Determine character at X/Y (exit if out-of-bounds)}
  dec(Y, ControlPanel.Height);
  if (Y < 0) or (Y > CharChartForm.ClientHeight - ControlPanel.Height - StatusPanel.Height - 2) then exit;
  case Mode of
    dmStandard   : begin {Standard Order View}
                   dec(X, (CharChartForm.ClientWidth div 2) - (((XSize+1) * 32) div 2)); {Adjust for possible smaller-than-window chart}
                   if (X < 0) or (X > (XSize+1) * 32 - 1) then exit;
                   CurChar := (X div (XSize+1)) + 32*(Y div (YSize+1));
                   Result := True;
                   end;
    dmROMBitmap  : begin
                   dec(X, (CharChartForm.ClientWidth div 2) - (((XSize+1) * 16) div 2)); {Adjust for possible smaller-than-window chart}
                   if (X < 0) or (X > (XSize+1) * 16 - 1) then exit;
                   CurChar := ((X div (XSize+1)) * 2) + 32*(Y div ((YSize+1)+(YSize mod 2))) + 1*ord(Y mod (YSize+1+(YSize mod 2)) > (YSize+1) div 2);
                   Result := True;
                   end;
    dmSymbolic   : begin {Symbolic Order View}
                   if (X < RowMetric[rmOffset, (Y div (YSize+1))]) or (X > RowMetric[rmOffset, (Y div (YSize+1))]+(XSize+1)*RowMetric[rmLength, (Y div (YSize+1))]-1) then exit;
                   CurChar := RowMetric[rmStartChar, (Y div (YSize+1))] + ((X - RowMetric[rmOffset, (Y div (YSize+1))]) div (XSize+1));
                   Result := True;
                   end;
  end;
end;

{------------------------------------------------------------------------------}

procedure TCharChartForm.UpdateStatus;
{Update status display for current selected character}
var
  ID   : Integer;
  Str1 : String;
  Str2 : String;
begin
  if Mode = dmSymbolic then ID := TranslateCharID(CurChar, dmSymbolic, dmStandard) else ID := CurChar;
  {Update character chart display and status display}
  PaintChart(True);
  Str1 := FontDesc[FontOrder[Mode, CurChar and ($FE + ord(Mode <> dmROMBitmap))] and $FF];
  if Mode = dmROMBitmap then
    begin
    Str2 := FontDesc[FontOrder[Mode, CurChar and $FE + 1] and $FF];
    if pos(leftstr(Str1, pos(':', Str1)), Str2) = 1 then
      Str1 := Str1 + ' and' + rightstr(Str2, length(Str2)-pos(':', Str1))
    else
      Str1 := Str1 + ' and ' + Str2;
    end;
  Caption := 'Character Chart - ' + Str1;
  Decimal.Caption := inttostr(ID);
  Hexadecimal.Caption := '$'+inttohex(ID, 2);
  Unicode.Caption := '$'+inttohex(FontMap[FontOrder[Mode, CurChar] and $FF], 4);
  ROM.Caption := '$'+inttohex($8000+CurChar*64 , 4)+' - $'+inttohex($803F+CurChar*64 , 4);
  StatusPanel.Update;
end;

{------------------------------------------------------------------------------}

function TCharChartForm.TranslateCharID(ID: Integer; FromMode, ToMode: TDisplayMode): Integer;
{Translate ID from Standard or ROMBitmap to Symbolic order's position or vice versa.}
begin
  if (FromMode = ToMode) or ((FromMode <> dmSymbolic) and (ToMode <> dmSymbolic)) then
    Result := ID
  else
    begin
    Result := 0;
    if not ((FromMode <> dmSymbolic) and (ToMode = dmSymbolic)) then
      while (FontOrder[dmStandard, Result] <> FontOrder[dmSymbolic, ID] and $FF) do inc(Result)   {Symbolic to non-symbolic}
    else
      begin
      while (FontOrder[dmSymbolic, Result] and $FF <> FontOrder[dmStandard, ID]) do inc(Result);  {Non-symbolic to symbolic}
      if (FontOrder[dmSymbolic, Result] >= X) then Result := 0;
      end;
    end;
end;

{------------------------------------------------------------------------------}

function TCharChartForm.GetDisplayMode: Integer;
{Return the current display mode as a number.  0 = dmStandard, 1 = dmROMBitmap, 2 = dmSymbolic}
begin
  Result := ord(Mode);
end;

{------------------------------------------------------------------------------}

procedure TCharChartForm.SetDisplayMode(Value: Integer);
{Set the display mode.  0 = dmStandard, 1 = dmROMBitmap, 2 = dmSymbolic}
begin
  Mode := TDisplayMode(max(ord(low(TDisplayMode)), min(ord(high(TDisplayMode)), Value)));
  case Mode of
    dmStandard  : StandardOrderButton.Checked := True;
    dmROMBitmap : ROMBitmapButton.Checked := True;
    dmSymbolic  : SymbolicOrderButton.Checked := True;
  end;
  SetChartSize;
  PaintChart(False);
  UpdateStatus;
end;

{------------------------------------------------------------------------------}

procedure TCharChartForm.SetFontPtSize(Value: Integer);
{Sets font size and draw font set in memory.  Value is limited to even values of 2..128}
var
  Idx : Integer;
  Char : WideString;
begin
  FontBitmap.Canvas.Font.Size := Editor.GetNextFontSize(max(2, min(128, Value)) and $FE, True, True);
  FontPtSize.Caption := inttostr(FontBitmap.Canvas.Font.Size);
  {Determine X and Y size of characters at new font size}
  XSize := WideCanvasTextWidth(FontBitmap.Canvas, WideString(WideChar(FontMap[0])));
  YSize := WideCanvasTextHeight(FontBitmap.Canvas, WideString(WideChar(FontMap[0])));
  {Adjust size of FontBitmap to contain entire font set}
  FontBitmap.Width := XSize*32;
  FontBitmap.Height := YSize*8;
  FontBitmap.Canvas.FillRect(rect(0, 0, FontBitmap.Width, FontBitmap.Height));
  {Adjust size of CxxBitmaps to just one character}
  C01Bitmap.Width := XSize;
  C01Bitmap.Height := YSize;
  C01Bitmap.Canvas.FillRect(rect(0, 0, C01Bitmap.Width, C01Bitmap.Height));
  C10Bitmap.Width := XSize;
  C10Bitmap.Height := YSize;
  C10Bitmap.Canvas.FillRect(rect(0, 0, C10Bitmap.Width, C10Bitmap.Height));
  C11Bitmap.Width := XSize;
  C11Bitmap.Height := YSize;
  C11Bitmap.Canvas.FillRect(rect(0, 0, C11Bitmap.Width, C11Bitmap.Height));
  Scratch1Bitmap.Width := XSize;
  Scratch1Bitmap.Height := YSize;
  Scratch2Bitmap.Width := XSize;
  Scratch2Bitmap.Height := YSize;
  {Draw entire font set}
  for Idx := 0 to 255 do
    begin
    Char := WideString(WideChar(FontMap[Idx]));
    WideCanvasTextOut(FontBitmap.Canvas, XSize * (Idx mod 32), YSize * (Idx div 32), Char);
    end;
end;

{------------------------------------------------------------------------------}

function TCharChartForm.GetFontName: String;
{Get chart font name}
begin
  Result := FontBitmap.Canvas.Font.Name;
end;

{------------------------------------------------------------------------------}

procedure TCharChartForm.SetFontName(FontName: String);
{Set font, by name, in chart}
begin
  FontBitmap.Canvas.Font.Name := FontName;
end;

{------------------------------------------------------------------------------}

function TCharChartForm.GetFontSize: Integer;
{Return current font size}
begin
  Result := FontBitmap.Canvas.Font.Size;
end;

{------------------------------------------------------------------------------}

procedure TCharChartForm.SetFontSize(Value: Integer);
{Set font size and resize chart}
begin
  SetFontPtSize(Value);
  SetChartSize;
end;

{------------------------------------------------------------------------------}

procedure TCharChartForm.IncFontSize;
{Increment font size}
begin
  SetFontSize(Editor.GetNextFontSize(FontBitmap.Canvas.Font.Size, True, False));
  SetChartSize;
end;

{------------------------------------------------------------------------------}

procedure TCharChartForm.DecFontSize;
{Decrement font size}
begin
  SetFontSize(Editor.GetNextFontSize(FontBitmap.Canvas.Font.Size, False, False));
  SetChartSize;
end;

{------------------------------------------------------------------------------}

procedure TCharChartForm.InsertChar;
{Insert character into the active edit control}
begin
 if not (FontOrder[Mode, CurChar] and $FF in [$0..$1, $8..$D]) then
    begin
    Editor.ActiveSource.InsertString(WideString(WideChar(FontMap[FontOrder[Mode, CurChar] and $FF])));
    Editor.ActiveSource.MoveRight;
    end
  else
    messagebeep(MB_OK);
end;

{------------------------------------------------------------------------------}

Initialization
  FontBitmap := TBitmap.Create;
  FontBitmap.Canvas.Font.Color := ChartFtColor;
  BuffBitmap := TBitmap.Create;
  BuffBitmap.Canvas.Pen.Color := ChartFtColor;
  C01Bitmap := TBitmap.Create;
  C01Bitmap.Canvas.Brush.Color := Color01;
  C10Bitmap := TBitmap.Create;
  C10Bitmap.Canvas.Brush.Color := Color10;
  C11Bitmap := TBitmap.Create;
  C11Bitmap.Canvas.Brush.Color := Color11;
  Scratch1Bitmap := TBitmap.Create;
  Scratch2Bitmap := TBitmap.Create;
  CurChar := 0;
  PrevChar := 0;
  Mode := dmStandard;

end.
