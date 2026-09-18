import java.util.ArrayList;
import java.util.List;

// Lớp hỗ trợ tọa độ điểm
class CDiem {
    protected float x;
    protected float y;

    public CDiem() {
        this.x = 0;
        this.y = 0;
    }

    public CDiem(float x, float y) {
        this.x = x;
        this.y = y;
    }

    // Tính khoảng cách giữa hai điểm
    public float khoangCach(CDiem d) {
        return (float) Math.sqrt(Math.pow(this.x - d.x, 2) + Math.pow(this.y - d.y, 2));
    }

    @Override
    public String toString() {
        return "(" + x + ", " + y + ")";
    }
}

// Lớp cơ sở (Base Class)
abstract class CHinhVe {
    protected int maLoaiHinhVe;

    public CHinhVe() {
        this.maLoaiHinhVe = 0;
    }

    public abstract float dienTich();

    public abstract float chuVi();

    public abstract void ve();
}

// Lớp Tam Giác kế thừa CHinhVe
class CTamGiac extends CHinhVe {
    protected CDiem p1;
    protected CDiem p2;
    protected CDiem p3;

    public CTamGiac() {
        super();
        this.maLoaiHinhVe = 1;
        this.p1 = new CDiem(0, 0);
        this.p2 = new CDiem(0, 3);
        this.p3 = new CDiem(4, 0);
    }

    public CTamGiac(CDiem p1, CDiem p2, CDiem p3) {
        super();
        this.maLoaiHinhVe = 1;
        this.p1 = p1;
        this.p2 = p2;
        this.p3 = p3;
    }

          @Override
    public float chuVi() {
        float a = p1.khoangCach(p2);
        float b = p2.khoangCach(p3);
        float c = p3.khoangCach(p1);
        return a + b + c;
    }

    @Override
    public float dienTich() {
        float a = p1.khoangCach(p2);
        float b = p2.khoangCach(p3);
        float c = p3.khoangCach(p1);
        float p = (a + b + c) / 2.0f;
        return (float) Math.sqrt(p * (p - a) * (p - b) * (p - c));
    }

    @Override
    public void ve() {
        System.out.println("Vẽ hình tam giác nối 3 đỉnh: " + p1 + ", " + p2 + ", " + p3);
    }
}

// Lớp Tứ Giác kế thừa CHinhVe
class CTuGiac extends CHinhVe {
    protected CDiem p1;
    protected CDiem p2;
    protected CDiem p3;
    protected CDiem p4;

    public CTuGiac() {
        super();
        this.maLoaiHinhVe = 2;
        this.p1 = new CDiem(0, 0);
        this.p2 = new CDiem(0, 4);
        this.p3 = new CDiem(4, 4);
        this.p4 = new CDiem(4, 0);
    }

    public CTuGiac(CDiem p1, CDiem p2, CDiem p3, CDiem p4) {
        super();
        this.maLoaiHinhVe = 2;
        this.p1 = p1;
        this.p2 = p2;
        this.p3 = p3;
        this.p4 = p4;
    }

    @Override
    public float chuVi() {
        return p1.khoangCach(p2) + p2.khoangCach(p3) + p3.khoangCach(p4) + p4.khoangCach(p1);
    }

    @Override
    public float dienTich() {
        // Chia tứ giác lồi thành hai tam giác (p1, p2, p3) và (p1, p3, p4) để tính diện
        // tích
        float a1 = p1.khoangCach(p2), b1 = p2.khoangCach(p3), c1 = p3.khoangCach(p1);
        float p_t1 = (a1 + b1 + c1) / 2.0f;
        float s1 = (float) Math.sqrt(p_t1 * (p_t1 - a1) * (p_t1 - b1) * (p_t1 - c1));

        float a2 = p1.khoangCach(p3), b2 = p3.khoangCach(p4), c2 = p4.khoangCach(p1);
        float p_t2 = (a2 + b2 + c2) / 2.0f;
        float s2 = (float) Math.sqrt(p_t2 * (p_t2 - a2) * (p_t2 - b2) * (p_t2 - c2));

        return s1 + s2;
    }

    @Override
    public void ve() {
        System.out.println("Vẽ hình tứ giác nối 4 đỉnh: " + p1 + ", " + p2 + ", " + p3 + ", " + p4);
    }
}

// Lớp Ellipse kế thừa CHinhVe
class CEllipse extends CHinhVe {
    protected CDiem tam;
    protected float a; // Bán trục lớn
    protected float b; // Bán trục nhỏ

    public CEllipse() {
        super();
        this.maLoaiHinhVe = 3;
        this.tam = new CDiem(0, 0);
        this.a = 5.0f;
        this.b = 3.0f;
    }

    public CEllipse(CDiem tam, float a, float b) {
        super();
        this.maLoaiHinhVe = 3;
        this.tam = tam;
        this.a = a;
        this.b = b;
    }

    @Override
    public float chuVi() {
        // Công thức xấp xỉ chu vi elip của Ramanujan
        return (float) (Math.PI * (3 * (a + b) - Math.sqrt((3 * a + b) * (a + 3 * b))));
    }

    @Override
    public float dienTich() {
        return (float) (Math.PI * a * b);
    }

    @Override
    public void ve() {
        System.out.println("Vẽ hình Ellipse tại tâm " + tam + " với bán trục a = " + a + ", b = " + b);
    }
}

// Hàm thực thi chính
public class Main {
    public static void main(String[] args) {
        List<CHinhVe> danhSachHinh = new ArrayList<>();

        danhSachHinh.add(new CTamGiac(new CDiem(0, 0), new CDiem(0, 3), new CDiem(4, 0)));
        danhSachHinh.add(new CTuGiac(new CDiem(0, 0), new CDiem(0, 2), new CDiem(4, 2), new CDiem(4, 0)));
        danhSachHinh.add(new CEllipse(new CDiem(2, 3), 6.0f, 4.0f));

        // Duyệt danh sách để thể hiện tính đa hình
        for (CHinhVe hinh : danhSachHinh) {
            hinh.ve();
            System.out.printf("- Chu vi: %.2f\n", hinh.chuVi());
            System.out.printf("- Diện tích: %.2f\n", hinh.dienTich());
            System.out.println("------------------------------------");
        }
    }
}
