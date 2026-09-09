export type GeneralQuestioner = {
  order: number;
  name: string;
  group: string;
  themes: string[];
};

export type GeneralQuestionDay = {
  date: string;
  pdfUrl: string;
  questioners: GeneralQuestioner[];
};

export const TOKOROZAWA_GENERAL_QUESTION_DAYS: GeneralQuestionDay[] = [
  {
    date: "9月15日（火）",
    pdfUrl:
      "https://www.city.tokorozawa.saitama.jp/shigikai/shingi/r8dai5/202609ippan.files/915.pdf",
    questioners: [
      {
        order: 1,
        name: "花岡 健太",
        group: "日本共産党所沢市議団",
        themes: [
          "農業・学校給食",
          "社会教育",
          "地域医療",
          "公共交通",
          "防災",
          "障害福祉",
          "学童",
        ],
      },
      {
        order: 2,
        name: "秋田 孝",
        group: "至誠自民クラブ",
        themes: [
          "鉄道直通運転",
          "子宮頸がんワクチン",
          "自転車のまちづくり",
          "卸売市場・道の駅",
          "溢水対策",
        ],
      },
      {
        order: 3,
        name: "斎藤 由紀",
        group: "至誠自民クラブ",
        themes: [
          "障がい者支援",
          "地域公共交通",
          "地域特性を活かすまちづくり",
          "地域防災",
        ],
      },
      {
        order: 4,
        name: "石原 昂",
        group: "自由民主党・維新・参政・無所属の会",
        themes: ["新所沢パルコ跡地", "国民保護・危機管理", "中核市移行"],
      },
      {
        order: 5,
        name: "矢作 いづみ",
        group: "日本共産党所沢市議団",
        themes: [
          "災害・防災",
          "指定管理者制度",
          "子育て支援",
          "障害者支援",
          "地域公共交通",
        ],
      },
      {
        order: 6,
        name: "谷口 雅典",
        group: "至誠自民クラブ",
        themes: [
          "とこペイ",
          "学校備品",
          "朝の小1の壁",
          "交通安全",
          "太陽光発電",
        ],
      },
    ],
  },
  {
    date: "9月16日（水）",
    pdfUrl:
      "https://www.city.tokorozawa.saitama.jp/shigikai/shingi/r8dai5/202609ippan.files/916.pdf",
    questioners: [
      {
        order: 7,
        name: "石本 亮三",
        group: "立憲リベラルの会",
        themes: ["旧ネオポリス長生クラブ会館", "技術職員", "低年齢児の保育"],
      },
      {
        order: 8,
        name: "川辺 浩直",
        group: "公明党",
        themes: ["道路安全", "新所沢駅周辺", "学校体育館", "防災・減災"],
      },
      {
        order: 9,
        name: "大舘 隆行",
        group: "至誠自民クラブ",
        themes: ["市政", "消防組合", "駐車場", "公有財産", "空き家"],
      },
      {
        order: 10,
        name: "島田 一隆",
        group: "さきがけ",
        themes: ["防災", "学校教育", "猛暑対策", "職員採用"],
      },
      {
        order: 11,
        name: "神戸 鉄郎",
        group: "自由民主党・維新・参政・無所属の会",
        themes: [
          "年金申請支援",
          "図書館",
          "学校教育",
          "保護者負担",
          "共同親権",
        ],
      },
      {
        order: 12,
        name: "中井 めぐみ",
        group: "日本共産党所沢市議団",
        themes: ["環境施策", "職員確保", "加齢性難聴", "道路行政"],
      },
    ],
  },
  {
    date: "9月17日（木）",
    pdfUrl:
      "https://www.city.tokorozawa.saitama.jp/shigikai/shingi/r8dai5/202609ippan.files/917.pdf",
    questioners: [
      {
        order: 13,
        name: "福原 浩昭",
        group: "公明党",
        themes: ["財政余力", "行政サービス検証", "公益的福祉ストック"],
      },
      {
        order: 14,
        name: "長岡 恵子",
        group: "立憲民主党・無所属の会",
        themes: [
          "病児保育",
          "松戸橋",
          "高齢者の移動",
          "土地区画整理",
          "水の安全",
        ],
      },
      {
        order: 15,
        name: "入沢 豊",
        group: "自由民主党・維新・参政・無所属の会",
        themes: ["市の広告", "西武球場前駅開発"],
      },
      {
        order: 16,
        name: "大石 健一",
        group: "至誠自民クラブ",
        themes: [
          "旧町まちづくり",
          "保健医療と都市計画",
          "航空記念公園",
          "農業・学校給食",
        ],
      },
      {
        order: 17,
        name: "前田 浩昭",
        group: "自由民主党・維新・参政・無所属の会",
        themes: ["北野公園市民プール", "公園の電源", "ロケ撮影・観光"],
      },
      {
        order: 18,
        name: "大久保 竜一",
        group: "公明党",
        themes: ["予防接種", "とこペイ", "デジタル戦略"],
      },
    ],
  },
  {
    date: "9月18日（金）",
    pdfUrl:
      "https://www.city.tokorozawa.saitama.jp/shigikai/shingi/r8dai5/202609ippan.files/918.pdf",
    questioners: [
      {
        order: 19,
        name: "松本 明信",
        group: "市民クラブ未来",
        themes: ["危機管理", "物価高騰", "農地"],
      },
      {
        order: 20,
        name: "佐野 允彦",
        group: "自由民主党・維新・参政・無所属の会",
        themes: ["福祉防災", "情報管理", "ドローン", "害虫対策", "教育"],
      },
      {
        order: 21,
        name: "赤川 洋二",
        group: "立憲民主党・無所属の会",
        themes: ["防災対策", "障がい者支援", "系統用蓄電施設"],
      },
      {
        order: 22,
        name: "亀山 恭子",
        group: "公明党",
        themes: ["子育て・睡眠", "危険木", "動物愛護", "生命の安全教育"],
      },
      {
        order: 23,
        name: "荻野 泰男",
        group: "さきがけ",
        themes: [
          "市政運営",
          "職員の副業",
          "地域づくり",
          "文化的処方",
          "熱中症",
          "下水道",
        ],
      },
      {
        order: 24,
        name: "斉藤 かおり",
        group: "自由民主党・維新・参政・無所属の会",
        themes: ["視覚障がい者", "中核市・保健所", "地域医療", "大規模震災"],
      },
    ],
  },
  {
    date: "9月24日（木）",
    pdfUrl:
      "https://www.city.tokorozawa.saitama.jp/shigikai/shingi/r8dai5/202609ippan.files/924.pdf",
    questioners: [
      {
        order: 25,
        name: "山口 浩美",
        group: "公明党",
        themes: ["災害対策", "医療的ケア児・者", "放課後児童クラブ"],
      },
      {
        order: 26,
        name: "小林 澄子",
        group: "日本共産党所沢市議団",
        themes: [
          "非核三原則",
          "認知症",
          "気候対策",
          "自治体病院",
          "大学学費",
          "庁舎食堂",
        ],
      },
      {
        order: 27,
        name: "長谷川 礼奈",
        group: "さきがけ",
        themes: ["市民向け通知", "デジタル郵便"],
      },
    ],
  },
];
