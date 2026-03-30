export type RawHanjaRow = {
  id: string; // doc id (U+XXXX)
  hanja: string;
  음: string;
  훈: string;
  전체: string;
  훈음: string;
  구분: string;
};

export type RawHanjaDraft = {
  hanja: string;
  음: string;
  훈: string;
  전체: string;
  훈음: string;
  구분: string;
};

export type CsvPreview = {
  headers: string[];
  rows: Record<string, string>[];
};

