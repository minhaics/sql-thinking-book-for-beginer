#!/usr/bin/env python3
"""
Sinh dữ liệu mẫu cho CSDL "Chợ Nhà Ta".

- Tất định (deterministic): cùng --seed → cùng dữ liệu → đáp án bài tập luôn khớp.
- Chỉ dùng thư viện chuẩn Python 3.9+.
- Xuất file SQL dùng lệnh COPY (nhanh, chạy được bằng psql).

Cách dùng:
    python3 generate_seed.py                       # quy mô chuẩn (dùng cho bài tập)
    python3 generate_seed.py --scale 50 -o big.sql # quy mô lớn (dùng cho Phần III: index, EXPLAIN)

Lưu ý: đáp án/verify của bài tập được tính trên quy mô chuẩn (--scale 1 --seed 2024).
"""
import argparse
import random
import unicodedata
from decimal import Decimal, ROUND_HALF_UP
from datetime import date, datetime, timedelta

START = date(2024, 1, 1)
END = date(2025, 12, 31)

# 34 tỉnh/thành sau sắp xếp đơn vị hành chính 2025 — (tên, vùng, trọng số dân cư mua sắm)
PROVINCES = [
    ("Hà Nội", "Bắc", 18), ("Hải Phòng", "Bắc", 4), ("Tuyên Quang", "Bắc", 1), ("Cao Bằng", "Bắc", 1),
    ("Lai Châu", "Bắc", 1), ("Lào Cai", "Bắc", 1), ("Thái Nguyên", "Bắc", 2), ("Điện Biên", "Bắc", 1),
    ("Lạng Sơn", "Bắc", 1), ("Sơn La", "Bắc", 1), ("Phú Thọ", "Bắc", 2), ("Bắc Ninh", "Bắc", 3),
    ("Quảng Ninh", "Bắc", 2), ("Hưng Yên", "Bắc", 2), ("Ninh Bình", "Bắc", 2),
    ("Huế", "Trung", 2), ("Đà Nẵng", "Trung", 5), ("Thanh Hóa", "Trung", 3), ("Nghệ An", "Trung", 3),
    ("Hà Tĩnh", "Trung", 1), ("Quảng Trị", "Trung", 1), ("Quảng Ngãi", "Trung", 2), ("Gia Lai", "Trung", 2),
    ("Khánh Hòa", "Trung", 2), ("Lâm Đồng", "Trung", 2), ("Đắk Lắk", "Trung", 2),
    ("TP. Hồ Chí Minh", "Nam", 22), ("Cần Thơ", "Nam", 3), ("Đồng Nai", "Nam", 4), ("Tây Ninh", "Nam", 2),
    ("Vĩnh Long", "Nam", 2), ("Đồng Tháp", "Nam", 2), ("Cà Mau", "Nam", 1), ("An Giang", "Nam", 2),
]

SURNAMES = [("Nguyễn", 30), ("Trần", 11), ("Lê", 9), ("Phạm", 7), ("Hoàng", 5), ("Huỳnh", 4), ("Phan", 4),
            ("Vũ", 4), ("Võ", 4), ("Đặng", 3), ("Bùi", 3), ("Đỗ", 3), ("Hồ", 2), ("Ngô", 2), ("Dương", 2), ("Lý", 1)]
MIDDLE_M = ["Văn", "Minh", "Đức", "Quang", "Hữu", "Công", "Thành", "Gia", "Anh", "Tuấn"]
MIDDLE_F = ["Thị", "Ngọc", "Thu", "Minh", "Thanh", "Phương", "Bảo", "Khánh", "Mai", "Hoài"]
GIVEN_M = ["An", "Bình", "Cường", "Dũng", "Hải", "Hiếu", "Hùng", "Huy", "Khang", "Khoa", "Long", "Nam",
           "Phong", "Phúc", "Quân", "Sơn", "Tài", "Thắng", "Toàn", "Trung", "Tùng", "Việt", "Vinh", "Đạt"]
GIVEN_F = ["Anh", "Chi", "Diệp", "Dung", "Giang", "Hà", "Hạnh", "Hoa", "Hương", "Lan", "Linh", "Mai",
           "My", "Nga", "Ngân", "Nhung", "Oanh", "Phương", "Quyên", "Thảo", "Trang", "Uyên", "Vân", "Yến"]
STREETS = ["Lê Lợi", "Trần Hưng Đạo", "Nguyễn Huệ", "Hai Bà Trưng", "Lý Thường Kiệt", "Quang Trung",
           "Hùng Vương", "Điện Biên Phủ", "Phan Chu Trinh", "Nguyễn Trãi", "Bạch Đằng", "Võ Thị Sáu"]

# US / International constants (for LANG == 'en')
SURNAMES_EN = [("Smith", 30), ("Johnson", 11), ("Williams", 9), ("Brown", 7), ("Jones", 5),
               ("Garcia", 4), ("Miller", 4), ("Davis", 4), ("Rodriguez", 4), ("Martinez", 3),
               ("Hernandez", 3), ("Lopez", 3), ("Wilson", 2), ("Anderson", 2), ("Taylor", 2), ("Thomas", 1)]
FIRST_M_EN = ["James", "John", "Robert", "Michael", "William", "David", "Richard", "Joseph",
              "Thomas", "Charles", "Christopher", "Daniel", "Matthew", "Anthony", "Mark", "Donald",
              "Steven", "Paul", "Andrew", "Joshua", "Kevin", "Brian", "George", "Edward"]
FIRST_F_EN = ["Mary", "Patricia", "Jennifer", "Linda", "Elizabeth", "Barbara", "Susan", "Jessica",
              "Sarah", "Karen", "Lisa", "Nancy", "Betty", "Margaret", "Sandra", "Ashley",
              "Kimberly", "Emily", "Donna", "Michelle", "Carol", "Amanda", "Melissa", "Deborah"]
STREETS_EN = ["Main St", "Broadway", "Park Ave", "Oak St", "Maple Ave", "Washington St",
              "Lakeview Dr", "Sunset Blvd", "Lincoln Way", "Highland Ave", "Elm St", "Cedar Rd"]
EMAIL_DOMAINS = ["gmail.com", "gmail.com", "gmail.com", "yahoo.com", "outlook.com", "mail.com"]

# Cây danh mục: (tên cấp 1, [(tên cấp 2, [(lá, khoảng giá, mẫu tên sản phẩm)])])
CATEGORY_TREE = [
    ("Điện tử", [
        ("Điện thoại & Máy tính bảng", [
            ("Điện thoại", (2_500_000, 30_000_000), ["Điện thoại {b} {m}"]),
            ("Máy tính bảng", (3_000_000, 25_000_000), ["Máy tính bảng {b} Tab {m}"]),
        ]),
        ("Máy tính & Laptop", [
            ("Laptop", (9_000_000, 45_000_000), ["Laptop {b} {m}"]),
            ("Bàn phím & Chuột", (150_000, 3_000_000), ["Bàn phím cơ {b} K{m}", "Chuột không dây {b} M{m}"]),
        ]),
        ("Âm thanh", [
            ("Tai nghe", (200_000, 8_000_000), ["Tai nghe bluetooth {b} {m}"]),
            ("Loa", (300_000, 10_000_000), ["Loa di động {b} {m}"]),
        ]),
    ]),
    ("Thời trang", [
        ("Thời trang nam", [
            ("Áo nam", (120_000, 900_000), ["Áo thun nam {b} {m}", "Áo sơ mi nam {b} {m}"]),
            ("Quần nam", (180_000, 1_200_000), ["Quần jean nam {b} {m}", "Quần kaki nam {b} {m}"]),
        ]),
        ("Thời trang nữ", [
            ("Váy đầm", (200_000, 1_800_000), ["Đầm dự tiệc {b} {m}", "Váy công sở {b} {m}"]),
            ("Túi xách", (250_000, 5_000_000), ["Túi xách nữ {b} {m}"]),
        ]),
        ("Giày dép", [
            ("Giày thể thao", (350_000, 4_000_000), ["Giày chạy bộ {b} {m}"]),
        ]),
    ]),
    ("Nhà cửa & Đời sống", [
        ("Nhà bếp", [
            ("Nồi chảo", (150_000, 3_500_000), ["Bộ nồi inox {b} {m}", "Chảo chống dính {b} {m}"]),
            ("Đồ điện gia dụng", (400_000, 12_000_000), ["Nồi chiên không dầu {b} {m}", "Máy xay sinh tố {b} {m}"]),
        ]),
        ("Trang trí", [
            ("Đèn", (100_000, 2_500_000), ["Đèn ngủ {b} {m}"]),
        ]),
    ]),
    ("Sách & Văn phòng phẩm", [
        ("Sách", [
            ("Sách kỹ năng", (60_000, 350_000), ["Sách: Kỹ năng {m}"]),
            ("Sách lập trình", (120_000, 600_000), ["Sách: Lập trình {m}"]),
        ]),
        ("Văn phòng phẩm", [
            ("Bút & Sổ", (10_000, 400_000), ["Sổ tay {b} {m}", "Bút gel {b} {m}"]),
        ]),
    ]),
    ("Sắc đẹp & Sức khoẻ", [
        ("Chăm sóc da", [
            ("Kem chống nắng", (90_000, 900_000), ["Kem chống nắng {b} SPF{m}"]),
            ("Sữa rửa mặt", (60_000, 600_000), ["Sữa rửa mặt {b} {m}"]),
        ]),
        ("Thực phẩm chức năng", [
            ("Vitamin", (100_000, 1_500_000), ["Vitamin tổng hợp {b} {m}"]),
        ]),
    ]),
]
BRANDS = ["Sao Mai", "Lotus", "Hải Âu", "Việt Tiến Xa", "An Phát", "Mekong", "Trường Sơn", "Hoa Sen",
          "NovaTech", "Zenit", "Kira", "Orca", "Phượng Hoàng", "Bách Việt", "Luna", "Tre Xanh"]
SHOP_PREFIX = ["Nhà", "Tiệm", "Góc", "Kho", "Thế Giới", "Chợ", "Siêu Thị", "Cửa Hàng"]
SHOP_WORD = ["Công Nghệ", "Thời Trang", "Gia Dụng", "Sách Hay", "Làm Đẹp", "Đồ Xinh", "Tiện Ích", "Số",
             "Phong Cách", "Xanh", "Việt", "Hạnh Phúc", "Mặt Trời", "Bình An", "Ánh Dương"]
CARRIERS = ["Giao Siêu Tốc", "Chim Én Express", "Bưu Tín", "Lạc Đà Logistics"]
WAREHOUSES = [("Kho Hà Nội", "Hà Nội"), ("Kho Đà Nẵng", "Đà Nẵng"), ("Kho TP.HCM", "TP. Hồ Chí Minh")]
COMMENTS_GOOD = ["Hàng đẹp, đúng mô tả", "Giao nhanh, đóng gói cẩn thận", "Rất hài lòng", "Chất lượng tốt so với giá",
                 "Sẽ ủng hộ shop lần sau", "Tuyệt vời!"]
COMMENTS_MID = ["Tạm được", "Hàng ổn nhưng giao hơi lâu", "Đúng giá tiền", "Màu hơi khác ảnh"]
COMMENTS_BAD = ["Hàng lỗi, thất vọng", "Giao sai mẫu", "Chất lượng kém", "Shop phản hồi chậm"]


# ---------------------------------------------------------------------------
# LOCALIZATION. Data is ALWAYS generated from the Vietnamese constants above (so the
# random stream — and therefore every number — is identical in both languages);
# strings are translated only when written out.
# ---------------------------------------------------------------------------
LANG = "en"

EN = {
    # regions
    "Bắc": "North", "Trung": "Central", "Nam": "South",
    # 34 US State names mapping directly from the 34 provinces
    # 15 North states
    "Hà Nội": "New York", "Hải Phòng": "Pennsylvania", "Tuyên Quang": "Connecticut", "Cao Bằng": "Maine",
    "Lai Châu": "New Hampshire", "Lào Cai": "Rhode Island", "Thái Nguyên": "Vermont", "Điện Biên": "Delaware",
    "Lạng Sơn": "West Virginia", "Sơn La": "Maryland", "Phú Thọ": "Massachusetts", "Bắc Ninh": "New Jersey",
    "Quảng Ninh": "Ohio", "Hưng Yên": "Michigan", "Ninh Bình": "Wisconsin",
    # 11 Central states
    "Huế": "Colorado", "Đà Nẵng": "Illinois", "Thanh Hóa": "Indiana", "Nghệ An": "Missouri",
    "Hà Tĩnh": "Iowa", "Quảng Trị": "Kansas", "Quảng Ngãi": "Nebraska", "Gia Lai": "Oklahoma",
    "Khánh Hòa": "Minnesota", "Lâm Đồng": "Utah", "Đắk Lắk": "Arkansas",
    # 8 South states
    "TP. Hồ Chí Minh": "Texas", "Cần Thơ": "Florida", "Đồng Nai": "Georgia", "Tây Ninh": "North Carolina",
    "Vĩnh Long": "Virginia", "Đồng Tháp": "Tennessee", "Cà Mau": "Alabama", "An Giang": "Louisiana",
    # departments
    "Ban giám đốc": "Executive", "Kinh doanh": "Sales", "Vận hành": "Operations",
    "CSKH": "Customer Service", "Kỹ thuật": "Engineering",
    # categories
    "Điện tử": "Electronics", "Điện thoại & Máy tính bảng": "Phones & Tablets", "Điện thoại": "Smartphones",
    "Máy tính bảng": "Tablets", "Máy tính & Laptop": "Computers", "Laptop": "Laptops",
    "Bàn phím & Chuột": "Keyboards & Mice", "Âm thanh": "Audio", "Tai nghe": "Headphones", "Loa": "Speakers",
    "Thời trang": "Fashion", "Thời trang nam": "Men's Fashion", "Áo nam": "Men's Shirts", "Quần nam": "Men's Pants",
    "Thời trang nữ": "Women's Fashion", "Váy đầm": "Dresses", "Túi xách": "Handbags", "Giày dép": "Footwear",
    "Giày thể thao": "Sneakers", "Nhà cửa & Đời sống": "Home & Living", "Nhà bếp": "Kitchen",
    "Nồi chảo": "Cookware", "Đồ điện gia dụng": "Kitchen Appliances", "Trang trí": "Decor", "Đèn": "Lamps",
    "Sách & Văn phòng phẩm": "Books & Stationery", "Sách": "Books", "Sách kỹ năng": "Self-Help Books",
    "Sách lập trình": "Programming Books", "Văn phòng phẩm": "Stationery", "Bút & Sổ": "Pens & Notebooks",
    "Sắc đẹp & Sức khoẻ": "Beauty & Health", "Chăm sóc da": "Skincare", "Kem chống nắng": "Sunscreen",
    "Sữa rửa mặt": "Face Wash", "Thực phẩm chức năng": "Supplements", "Vitamin": "Vitamins",
    "Đồ chơi & Mẹ bé": "Toys & Baby",
    # product name templates
    "Điện thoại {b} {m}": "{b} Phone {m}", "Máy tính bảng {b} Tab {m}": "{b} Tab {m}",
    "Laptop {b} {m}": "{b} Laptop {m}", "Bàn phím cơ {b} K{m}": "{b} Mechanical Keyboard K{m}",
    "Chuột không dây {b} M{m}": "{b} Wireless Mouse M{m}", "Tai nghe bluetooth {b} {m}": "{b} Bluetooth Headphones {m}",
    "Loa di động {b} {m}": "{b} Portable Speaker {m}", "Áo thun nam {b} {m}": "{b} Men's T-Shirt {m}",
    "Áo sơ mi nam {b} {m}": "{b} Men's Shirt {m}", "Quần jean nam {b} {m}": "{b} Men's Jeans {m}",
    "Quần kaki nam {b} {m}": "{b} Men's Chinos {m}", "Đầm dự tiệc {b} {m}": "{b} Party Dress {m}",
    "Váy công sở {b} {m}": "{b} Office Dress {m}", "Túi xách nữ {b} {m}": "{b} Handbag {m}",
    "Giày chạy bộ {b} {m}": "{b} Running Shoes {m}", "Bộ nồi inox {b} {m}": "{b} Stainless Pot Set {m}",
    "Chảo chống dính {b} {m}": "{b} Non-Stick Pan {m}", "Nồi chiên không dầu {b} {m}": "{b} Air Fryer {m}",
    "Máy xay sinh tố {b} {m}": "{b} Blender {m}", "Đèn ngủ {b} {m}": "{b} Night Lamp {m}",
    "Sách: Kỹ năng {m}": "Book: Soft Skills {m}", "Sách: Lập trình {m}": "Book: Programming {m}",
    "Sổ tay {b} {m}": "{b} Notebook {m}", "Bút gel {b} {m}": "{b} Gel Pen {m}",
    "Kem chống nắng {b} SPF{m}": "{b} Sunscreen SPF{m}", "Sữa rửa mặt {b} {m}": "{b} Face Wash {m}",
    "Vitamin tổng hợp {b} {m}": "{b} Multivitamin {m}",
    # variant options
    "Mặc định": "Default", "Đen": "Black", "Trắng": "White", "Bản tiêu chuẩn": "Standard", "Bản cao cấp": "Premium",
    # shop name parts (EN order: WORD PREFIX)
    "Nhà": "House", "Tiệm": "Shop", "Góc": "Corner", "Kho": "Depot", "Thế Giới": "World", "Chợ": "Market",
    "Siêu Thị": "Mart", "Cửa Hàng": "Store", "Công Nghệ": "Tech", "Gia Dụng": "Home", "Sách Hay": "Books",
    "Làm Đẹp": "Beauty", "Đồ Xinh": "Goods", "Tiện Ích": "Smart", "Số": "Digital", "Phong Cách": "Style",
    "Xanh": "Green", "Việt": "Prime", "Hạnh Phúc": "Happy", "Mặt Trời": "Sun", "Bình An": "Nova",
    "Ánh Dương": "Apex",
    # warehouses & carriers
    "Kho Hà Nội": "New York Warehouse", "Kho Đà Nẵng": "Chicago Warehouse", "Kho TP.HCM": "Dallas Warehouse",
    "Giao Siêu Tốc": "SwiftShip", "Chim Én Express": "FedRelay", "Bưu Tín": "Apex Logistics",
    "Lạc Đà Logistics": "Metro Express",
    # brands
    "Sao Mai": "NovaTech", "Lotus": "Apex", "Hải Âu": "Horizon", "Việt Tiến Xa": "Summit",
    "An Phát": "Pulse", "Mekong": "Aura", "Trường Sơn": "Pioneer", "Hoa Sen": "Vanguard",
    "NovaTech": "Meridian", "Zenit": "Titan", "Kira": "Velocity", "Orca": "Crest",
    "Phượng Hoàng": "Lumina", "Bách Việt": "Solis", "Luna": "Nexus", "Tre Xanh": "Echo",
    # review comments
    "Hàng đẹp, đúng mô tả": "Looks great, exactly as described", "Giao nhanh, đóng gói cẩn thận": "Fast delivery, well packed",
    "Rất hài lòng": "Very satisfied", "Chất lượng tốt so với giá": "Great value for money",
    "Sẽ ủng hộ shop lần sau": "Will buy from this shop again", "Tuyệt vời!": "Excellent!",
    "Tạm được": "It's okay", "Hàng ổn nhưng giao hơi lâu": "Fine, but delivery was slow",
    "Đúng giá tiền": "You get what you pay for", "Màu hơi khác ảnh": "Color differs from the photos",
    "Hàng lỗi, thất vọng": "Defective, disappointed", "Giao sai mẫu": "Wrong item delivered",
    "Chất lượng kém": "Poor quality", "Shop phản hồi chậm": "Seller was slow to respond",
    # coupon
    "CHAOBANMOI": "WELCOME",
}


def strip_accents(s: str) -> str:
    s = s.replace("đ", "d").replace("Đ", "D")
    return "".join(c for c in unicodedata.normalize("NFD", s) if unicodedata.category(c) != "Mn")


def T(s):
    """Translate a Vietnamese data string for output (identity when LANG == 'vi')."""
    if LANG == "vi" or s is None:
        return s
    return EN.get(s, strip_accents(s))


# Variant option names that make sense for each kind of product (output-time only: same random stream).
VARIANT_BY_LEAF = {
    ("Điện thoại", "Máy tính bảng", "Laptop"): {"Size S": ("128GB", "128GB"), "Size M": ("256GB", "256GB"),
                                               "Size L": ("512GB", "512GB")},
    ("Bàn phím & Chuột", "Tai nghe", "Loa"): {"Size S": ("Mini", "Mini"), "Size M": ("Standard", "Tiêu chuẩn"),
                                             "Size L": ("Pro", "Pro")},
    ("Nồi chảo", "Đồ điện gia dụng", "Đèn"): {"Size S": ("Small", "Cỡ nhỏ"), "Size M": ("Medium", "Cỡ vừa"),
                                            "Size L": ("Large", "Cỡ lớn")},
    ("Sách kỹ năng", "Sách lập trình"): {"Đen": ("Paperback", "Bìa mềm"), "Trắng": ("Hardcover", "Bìa cứng"),
                                        "Size S": ("Pocket edition", "Khổ bỏ túi"), "Size M": ("Standard edition", "Khổ tiêu chuẩn"),
                                        "Size L": ("Large print", "Khổ lớn")},
    ("Bút & Sổ",): {"Size S": ("A6", "A6"), "Size M": ("A5", "A5"), "Size L": ("A4", "A4")},
    ("Kem chống nắng", "Sữa rửa mặt", "Vitamin"): {"Size S": ("50 ml", "50 ml"), "Size M": ("100 ml", "100 ml"),
                                                   "Size L": ("200 ml", "200 ml"),
                                                   "Đen": ("Travel size", "Bản du lịch"), "Trắng": ("Full size", "Bản đầy đủ")},
}


def variant_label(leaf: str, opt: str) -> str:
    for leaves, mapping in VARIANT_BY_LEAF.items():
        if leaf in leaves and opt in mapping:
            en, vi = mapping[opt]
            return vi if LANG == "vi" else en
    return T(opt)


def shop_name(prefix, word):
    return f"{prefix} {word}" if LANG == "vi" else f"{T(word)} {T(prefix)}"


def round_k(x) -> int:
    """Làm tròn tới hàng nghìn, nửa lên — giống ROUND(x, -3) của PostgreSQL."""
    return int((Decimal(str(x)) / 1000).quantize(Decimal(1), rounding=ROUND_HALF_UP) * 1000)


def ascii_slug(s: str) -> str:
    s = s.replace("đ", "d").replace("Đ", "D")
    s = unicodedata.normalize("NFD", s)
    return "".join(c for c in s if unicodedata.category(c) != "Mn").lower().replace(" ", "")


class Copy:
    """Gom các dòng rồi xuất dạng COPY ... FROM stdin."""

    def __init__(self, table, cols):
        self.table, self.cols, self.rows = table, cols, []

    def add(self, *vals):
        self.rows.append(vals)

    @staticmethod
    def fmt(v):
        if v is None:
            return r"\N"
        if isinstance(v, bool):
            return "t" if v else "f"
        if isinstance(v, datetime):
            return v.strftime("%Y-%m-%d %H:%M:%S")
        s = str(v)
        return s.replace("\\", "\\\\").replace("\t", "\\t").replace("\n", "\\n")

    def dump(self, out):
        out.write(f"COPY shop.{self.table} ({', '.join(self.cols)}) FROM stdin;\n")
        for r in self.rows:
            out.write("\t".join(self.fmt(v) for v in r) + "\n")
        out.write("\\.\n\n")


def rand_dt(rng, d: date, busy_evening=True) -> datetime:
    hour = rng.choices(range(24), weights=[1, 1, 1, 1, 1, 1, 2, 3, 4, 5, 5, 6, 7, 5, 4, 4, 5, 6, 7, 9, 10, 10, 8, 4])[0] \
        if busy_evening else rng.randint(8, 17)
    return datetime(d.year, d.month, d.day, hour, rng.randint(0, 59), rng.randint(0, 59))


def day_weight(d: date) -> float:
    """Mô phỏng tăng trưởng + mùa vụ: Tết, 9.9, 10.10, 11.11, 12.12, Black Friday."""
    growth = 1 + 0.9 * (d - START).days / (END - START).days
    w = growth
    if d.month == d.day and d.month in (9, 10, 11, 12):
        w *= 4.0                                  # ngày đôi sale
    if d.month == 11 and 22 <= d.day <= 29 and d.weekday() == 4:
        w *= 2.5                                  # Black Friday
    if (d.month == 1 and d.day >= 15) or (d.month == 2 and d.day <= 5):
        w *= 1.5                                  # mua sắm trước Tết
    if d.weekday() >= 5:
        w *= 1.2
    return w


def generate(scale: int, seed: int, out):
    rng = random.Random(seed)
    n_customers = 3000 * scale
    n_orders = 20000 * scale
    n_sellers = 60
    n_products = 500

    tables = []

    # ---- provinces
    t = Copy("provinces", ["province_id", "name", "region"])
    prov_ids, prov_w, prov_region = [], [], {}
    for i, (name, region, w) in enumerate(PROVINCES, start=1):
        t.add(i, T(name), T(region))
        prov_ids.append(i); prov_w.append(w); prov_region[i] = region
    prov_by_name = {p[0]: i for i, p in enumerate(PROVINCES, start=1)}
    tables.append(t)

    def person_name():
        if LANG == "en":
            sur = rng.choices([s for s, _ in SURNAMES_EN], weights=[w for _, w in SURNAMES_EN])[0]
            g = rng.choice("MF")
            _ = rng.choice(MIDDLE_M if g == "M" else MIDDLE_F)
            given = rng.choice(FIRST_M_EN if g == "M" else FIRST_F_EN)
            return g, f"{given} {sur}"
        sur = rng.choices([s for s, _ in SURNAMES], weights=[w for _, w in SURNAMES])[0]
        g = rng.choice("MF")
        if g == "M":
            return g, f"{sur} {rng.choice(MIDDLE_M)} {rng.choice(GIVEN_M)}"
        return g, f"{sur} {rng.choice(MIDDLE_F)} {rng.choice(GIVEN_F)}"

    # ---- employees (cây 4 cấp)
    t = Copy("employees", ["employee_id", "full_name", "department", "manager_id", "hire_date", "salary"])
    emp_id = 0
    sales_staff = []

    def add_emp(dept, manager, level):
        nonlocal emp_id
        emp_id += 1
        _, nm = person_name()
        base = {0: 120_000_000, 1: 60_000_000, 2: 32_000_000, 3: 15_000_000}[level]
        salary = round(base * rng.uniform(0.85, 1.25), -5)
        hire = date(2019, 1, 1) + timedelta(days=rng.randint(0, 365 * (2 + level)))
        t.add(emp_id, nm, T(dept), manager, hire, salary)
        return emp_id

    ceo = add_emp("Ban giám đốc", None, 0)
    for dept, n_leads, n_staff in [("Kinh doanh", 2, 5), ("Vận hành", 2, 4), ("CSKH", 1, 6), ("Kỹ thuật", 2, 3)]:
        head = add_emp(dept, ceo, 1)
        for _ in range(n_leads):
            lead = add_emp(dept, head, 2)
            for _ in range(n_staff):
                e = add_emp(dept, lead, 3)
                if dept == "Kinh doanh":
                    sales_staff.append(e)
    tables.append(t)

    # ---- customers + addresses
    tc = Copy("customers", ["customer_id", "full_name", "email", "phone", "gender", "birth_date", "signup_date", "referred_by"])
    ta = Copy("addresses", ["address_id", "customer_id", "province_id", "street", "is_default"])
    customers = []          # (id, signup_date, default_address_id, [address ids])
    addr_prov = {}
    addr_id = 0
    signup_span = (END - date(2023, 1, 1)).days
    for cid in range(1, n_customers + 1):
        g, nm = person_name()
        parts = nm.split()
        if LANG == "en":
            local = f"{ascii_slug(parts[0])}.{ascii_slug(parts[-1])}{cid}"
        else:
            local = f"{ascii_slug(parts[-1])}.{ascii_slug(parts[0])}{cid}"
        if rng.random() < 0.03:
            local = local.capitalize()                           # vài email viết hoa — bài tập LOWER()
        email = f"{local}@{rng.choice(EMAIL_DOMAINS)}"
        phone = None if rng.random() < 0.12 else "0" + rng.choice("3579") + "".join(rng.choices("0123456789", k=8))
        gender = None if rng.random() < 0.05 else g
        birth = None if rng.random() < 0.25 else date(1965, 1, 1) + timedelta(days=rng.randint(0, 365 * 42))
        # đăng ký phân bố từ 2023 → 2025, nghiêng về sau
        signup = date(2023, 1, 1) + timedelta(days=int(signup_span * (rng.random() ** 0.7)))
        referred = None
        if cid > 50 and rng.random() < 0.18:
            referred = rng.randint(1, cid - 1)
        tc.add(cid, nm, email, phone, gender, birth, signup, referred)
        home = rng.choices(prov_ids, weights=prov_w)[0]
        my_addrs = []
        for k in range(rng.choices([1, 2, 3], weights=[75, 20, 5])[0]):
            addr_id += 1
            p = home if k == 0 else rng.choices(prov_ids, weights=prov_w)[0]
            pool = STREETS_EN if LANG == "en" else STREETS
            street = f"{rng.randint(1, 399)} {rng.choice(pool)}"
            ta.add(addr_id, cid, p, street, k == 0)
            addr_prov[addr_id] = p
            my_addrs.append(addr_id)
        customers.append((cid, signup, my_addrs))
    tables += [tc, ta]

    # ---- sellers
    t = Copy("sellers", ["seller_id", "shop_name", "province_id", "account_manager_id", "is_official", "joined_date"])
    used = set()
    for sid in range(1, n_sellers + 1):
        while True:
            pre, word = rng.choice(SHOP_PREFIX), rng.choice(SHOP_WORD)
            nm = f"{pre} {word}"
            if nm not in used:
                used.add(nm); break
        p = rng.choices(prov_ids, weights=prov_w)[0]
        am = None if rng.random() < 0.1 else rng.choice(sales_staff)
        t.add(sid, shop_name(pre, word), p, am, rng.random() < 0.2, date(2022, 1, 1) + timedelta(days=rng.randint(0, 700)))
    tables.append(t)

    # ---- categories
    t = Copy("categories", ["category_id", "name", "parent_id"])
    cat_id = 0
    leaves = []  # (cat_id, price_range, templates)
    leaf_names = {}
    for l1, subs in CATEGORY_TREE:
        cat_id += 1; c1 = cat_id; t.add(c1, T(l1), None)
        for l2, lfs in subs:
            cat_id += 1; c2 = cat_id; t.add(c2, T(l2), c1)
            for leaf, pr, tmpl in lfs:
                cat_id += 1; t.add(cat_id, T(leaf), c2)
                leaves.append((cat_id, pr, tmpl))
                leaf_names[cat_id] = leaf
    cat_id += 1
    t.add(cat_id, T("Đồ chơi & Mẹ bé"), None)          # danh mục rỗng — bài tập LEFT JOIN / NOT EXISTS
    tables.append(t)

    # ---- products + variants
    tp = Copy("products", ["product_id", "seller_id", "category_id", "name", "brand", "created_at", "is_active"])
    tv = Copy("product_variants", ["variant_id", "product_id", "sku", "variant_name", "price", "cost"])
    variants = []   # (variant_id, product_id, price, popularity)
    product_created = {}
    vid = 0
    pop_weights = {}
    for pid in range(1, n_products + 1):
        leaf_id, (lo, hi), tmpl = rng.choice(leaves)
        leaf_name = leaf_names[leaf_id]
        brand = None if rng.random() < 0.08 else rng.choice(BRANDS)
        template = rng.choice(tmpl)
        brand_out = T(brand)
        name = T(template).format(b=brand_out or "", m=rng.randint(10, 99)).replace("  ", " ").strip()
        created = date(2023, 6, 1) + timedelta(days=rng.randint(0, 900))
        product_created[pid] = created
        active = rng.random() > 0.06
        tp.add(pid, rng.randint(1, n_sellers), leaf_id, name, brand_out, created, active)
        base = rng.uniform(lo, hi) ** 1.0
        popularity = 0.0 if rng.random() < 0.04 else min(rng.paretovariate(1.3), 40.0) * (1.0 if active else 0.2)   # ~4% hàng ế
        options = rng.choice([["Mặc định"], ["Đen", "Trắng"], ["Size S", "Size M", "Size L"], ["Bản tiêu chuẩn", "Bản cao cấp"]])
        for k, opt in enumerate(options):
            vid += 1
            price = round_k(base * (1 + 0.15 * k))
            cost = round_k(price * rng.uniform(0.55, 0.8))
            tv.add(vid, pid, f"SKU-{pid:04d}-{k + 1}", variant_label(leaf_name, opt), price, cost)
            variants.append((vid, pid, price))
            pop_weights[vid] = popularity / len(options)
    tables += [tp, tv]

    # ---- warehouses, inventory, carriers
    tw = Copy("warehouses", ["warehouse_id", "name", "province_id"])
    for i, (nm, pv) in enumerate(WAREHOUSES, start=1):
        tw.add(i, T(nm), prov_by_name[pv])
    ti = Copy("inventory", ["warehouse_id", "variant_id", "quantity"])
    for v, _, _ in variants:
        for w in (1, 2, 3):
            r = rng.random()
            if r < 0.15:
                continue                              # kho không kinh doanh mã này
            ti.add(w, v, 0 if r < 0.25 else rng.randint(1, 400))
    tcar = Copy("carriers", ["carrier_id", "name"])
    for i, nm in enumerate(CARRIERS, start=1):
        tcar.add(i, T(nm))
    tables += [tw, ti, tcar]

    # ---- coupons
    tcp = Copy("coupons", ["coupon_id", "code", "discount_type", "discount_value", "min_order_value", "valid_from", "valid_to"])
    coupons = []
    cpid = 0
    for y in (2024, 2025):
        for m in range(1, 13):
            cpid += 1
            vf = date(y, m, 1); vt = (date(y + (m == 12), m % 12 + 1, 1) - timedelta(days=1))
            coupons.append((cpid, "percent", 10, 300_000, vf, vt))
            tcp.add(cpid, f"{'THANG' if LANG == 'vi' else 'MONTH'}{m:02d}-{y}", "percent", 10, 300_000, vf, vt)
        for m in (9, 10, 11, 12):
            cpid += 1
            d = date(y, m, m)
            coupons.append((cpid, "fixed", 50_000, 250_000, d, d))
            tcp.add(cpid, f"SALE{m}{m}-{y}", "fixed", 50_000, 250_000, d, d)
    cpid += 1
    tcp.add(cpid, T("CHAOBANMOI"), "fixed", 30_000, 0, date(2024, 1, 1), date(2025, 12, 31))
    coupons.append((cpid, "fixed", 30_000, 0, date(2024, 1, 1), date(2025, 12, 31)))
    cpid += 1
    tcp.add(cpid, "VIP-2026", "percent", 20, 1_000_000, date(2026, 1, 1), date(2026, 3, 31))   # chưa từng được dùng
    tables.append(tcp)

    # ---- orders & con cháu
    days = [START + timedelta(days=i) for i in range((END - START).days + 1)]
    dweights = [day_weight(d) for d in days]
    order_days = sorted(rng.choices(days, weights=dweights, k=n_orders))

    # Khách "trung thành" mua nhiều (Pareto); 15% khách không bao giờ mua
    buyer_pool = [c for c in customers if rng.random() > 0.15]
    buyer_w = [min(rng.paretovariate(1.6), 25.0) for _ in buyer_pool]   # chặn trên: không có "siêu khách" phi thực tế
    var_ids = [v[0] for v in variants]
    var_w = [pop_weights[v] for v in var_ids]
    var_price = {v[0]: v[2] for v in variants}
    var_product = {v[0]: v[1] for v in variants}
    wh_by_region = {"Bắc": 1, "Trung": 2, "Nam": 3}

    to = Copy("orders", ["order_id", "customer_id", "address_id", "coupon_id", "order_date", "status"])
    toi = Copy("order_items", ["order_id", "variant_id", "quantity", "unit_price"])
    tpay = Copy("payments", ["payment_id", "order_id", "method", "amount", "status", "paid_at"])
    tsh = Copy("shipments", ["shipment_id", "order_id", "carrier_id", "warehouse_id", "shipping_fee", "shipped_at", "delivered_at"])
    trv = Copy("reviews", ["review_id", "customer_id", "product_id", "rating", "comment", "created_at"])
    pay_id = ship_id = rev_id = 0
    reviewed = set()

    for oid, od in enumerate(order_days, start=1):
        # chọn khách đã đăng ký trước ngày đặt
        for _ in range(20):
            cid, signup, addrs = rng.choices(buyer_pool, weights=buyer_w)[0]
            if signup <= od:
                break
        else:
            cid, signup, addrs = next(c for c in customers if c[1] <= od)
        address = addrs[0] if rng.random() < 0.8 else rng.choice(addrs)
        odt = rand_dt(rng, od)

        # dòng hàng
        n_items = rng.choices([1, 2, 3, 4, 5], weights=[55, 25, 11, 6, 3])[0]
        chosen = set()
        subtotal = 0
        lines = []
        for _ in range(n_items):
            v = rng.choices(var_ids, weights=var_w)[0]
            if v in chosen or product_created[var_product[v]] > od:
                continue
            chosen.add(v)
            qty = rng.choices([1, 2, 3], weights=[80, 15, 5])[0]
            drift = 1 - 0.08 * (END - od).days / 730           # giá cũ thấp hơn giá hiện tại
            if od.month == od.day and od.month >= 9:
                drift *= 0.85                                  # ngày sale
            unit = max(1000, round_k(var_price[v] * drift))
            lines.append((v, qty, unit))
            subtotal += qty * unit
        if not lines:
            v = rng.choices(var_ids, weights=var_w)[0]
            lines.append((v, 1, var_price[v])); subtotal = var_price[v]

        # mã giảm giá hợp lệ
        coupon, discount = None, 0
        if rng.random() < 0.18:
            valid = [c for c in coupons if c[4] <= od <= c[5] and subtotal >= c[3]]
            if valid:
                c = rng.choice(valid)
                coupon = c[0]
                discount = round_k(Decimal(subtotal) * c[2] / 100) if c[1] == "percent" else c[2]

        # trạng thái
        age = (END - od).days
        if age <= 2:
            status = rng.choice(["pending", "paid", "paid", "shipped"])
        elif age <= 6:
            status = rng.choices(["shipped", "delivered", "cancelled"], weights=[55, 40, 5])[0]
        else:
            status = rng.choices(["delivered", "cancelled", "returned"], weights=[85, 10, 5])[0]

        to.add(oid, cid, address, coupon, odt, status)
        for v, q, u in lines:
            toi.add(oid, v, q, u)

        # vận chuyển
        region = prov_region[addr_prov[address]]
        wh = wh_by_region[region] if rng.random() < 0.85 else rng.randint(1, 3)
        same = wh == wh_by_region[region]
        fee = 0 if subtotal >= 500_000 and rng.random() < 0.7 else (18_000 if same else 32_000)
        amount = max(0, subtotal - discount) + fee
        method = rng.choices(["cod", "card", "ewallet", "bank_transfer"], weights=[45, 15, 30, 10])[0]
        shipped_at = odt + timedelta(hours=rng.randint(4, 48))
        transit_days = rng.randint(1, 3) if same else rng.randint(2, 7)
        delivered_at = shipped_at + timedelta(days=transit_days, hours=rng.randint(0, 10))

        if status in ("shipped", "delivered", "returned"):
            ship_id += 1
            tsh.add(ship_id, oid, rng.choices([1, 2, 3, 4], weights=[40, 30, 20, 10])[0], wh, fee, shipped_at,
                    None if status == "shipped" else delivered_at)

        # thanh toán
        def pay(m, st, at, amt=amount):
            nonlocal pay_id
            pay_id += 1
            tpay.add(pay_id, oid, m, amt, st, at)

        if method != "cod":
            if rng.random() < 0.05:
                pay("card", "failed", odt + timedelta(minutes=1))          # thử thẻ thất bại trước
            if status == "pending":
                pass
            elif status == "cancelled":
                if rng.random() < 0.5:
                    pay(method, "success", odt + timedelta(minutes=3))
                    pay(method, "refunded", odt + timedelta(days=1))
            else:
                amt = amount
                if status == "delivered" and rng.random() < 0.004:
                    amt = amount - fee if fee else amount + 10_000   # lỗi hệ thống cố ý — bài đối soát K07
                pay(method, "success", odt + timedelta(minutes=3), amt)
                if status == "returned":
                    pay(method, "refunded", delivered_at + timedelta(days=rng.randint(2, 7)))
        else:
            if status in ("delivered", "returned"):
                pay("cod", "success", delivered_at)
                if status == "returned":
                    pay("bank_transfer", "refunded", delivered_at + timedelta(days=rng.randint(2, 7)))

        # đánh giá
        if status == "delivered":
            for v, _, _ in lines:
                p = var_product[v]
                if (cid, p) in reviewed or rng.random() > 0.35:
                    continue
                reviewed.add((cid, p))
                late = transit_days >= 5
                rating = rng.choices([1, 2, 3, 4, 5], weights=[8, 8, 15, 30, 39] if late else [3, 3, 9, 30, 55])[0]
                pool = COMMENTS_GOOD if rating >= 4 else COMMENTS_MID if rating == 3 else COMMENTS_BAD
                comment = None if rng.random() < 0.4 else rng.choice(pool)
                rev_at = delivered_at + timedelta(days=rng.randint(0, 14), hours=rng.randint(0, 23))
                rev_id += 1
                trv.add(rev_id, cid, p, rating, T(comment), rev_at)

    tables += [to, toi, tpay, tsh, trv]

    out.write("-- Sinh bởi tools/generate_seed.py — KHÔNG sửa tay.\n")
    out.write(f"-- scale={scale} seed={seed} lang={LANG}\n")
    out.write("SET client_encoding = 'UTF8';\nBEGIN;\n\n")
    for tb in tables:
        tb.dump(out)
    out.write("COMMIT;\nANALYZE;\n")
    return {tb.table: len(tb.rows) for tb in tables}


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--scale", type=int, default=1, help="hệ số nhân số khách & đơn hàng (mặc định 1)")
    ap.add_argument("--seed", type=int, default=2024, help="hạt giống ngẫu nhiên (mặc định 2024)")
    ap.add_argument("-o", "--output", default="02-seed.sql")
    ap.add_argument("--lang", choices=["en", "vi"], default="en", help="language of text data (numbers are identical)")
    args = ap.parse_args()
    global LANG
    LANG = args.lang
    with open(args.output, "w", encoding="utf-8") as f:
        counts = generate(args.scale, args.seed, f)
    width = max(len(k) for k in counts)
    for k, v in counts.items():
        print(f"  {k:<{width}}  {v:>9,}")
    print(f"→ {args.output}")


if __name__ == "__main__":
    main()
