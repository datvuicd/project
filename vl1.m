function vl1
    clear all;
    close all;

    % Khai báo biến ký hiệu
    syms x y;

    % Nhập hàm điện thế từ bàn phím dưới dạng chuỗi
    V_str = input('Nhập hàm điện thế V(x, y): ', 's');
    V = str2sym(V_str);

    % Tính các thành phần của điện trường
    Ex = -diff(V, x);
    Ey = -diff(V, y);

    % Tính mật độ năng lượng điện trường
    epsilon = 8.854e-12;
    u = 0.5 * epsilon * (Ex.^2 + Ey.^2);

    % Tạo lưới tọa độ
    [X, Y] = meshgrid(-4:0.1:4);

    % Kiểm tra biến có mặt trong biểu thức
    vars = symvar(V);

    % Thay thế giá trị tại lưới
    if ismember(x, vars) && ismember(y, vars)
        V_val = double(subs(V, {x, y}, {X, Y}));
        Ex_val = double(subs(Ex, {x, y}, {X, Y}));
        Ey_val = double(subs(Ey, {x, y}, {X, Y}));
        u_val = double(subs(u, {x, y}, {X, Y}));
    elseif ismember(x, vars)
        V_val = double(subs(V, x, X));
        Ex_val = double(subs(Ex, x, X));
        Ey_val = zeros(size(X));  % Không có thành phần theo y
        u_val = double(subs(u, x, X));
    elseif ismember(y, vars)
        V_val = double(subs(V, y, Y));
        Ex_val = zeros(size(Y));  % Không có thành phần theo x
        Ey_val = double(subs(Ey, y, Y));
        u_val = double(subs(u, y, Y));
    else
        V_val = double(V) * ones(size(X));
        Ex_val = zeros(size(X));
        Ey_val = zeros(size(X));
        u_val = double(u) * ones(size(X));
    end

    % Vẽ đồ thị điện thế
    figure(1);
    surf(X, Y, V_val);
    xlabel('x'); ylabel('y'); zlabel('Thế điện V');
    title('Phân bố điện thế');
    shading interp; colormap jet; colorbar;

    % Vẽ vector điện trường
    figure(2);
    quiver(X, Y, Ex_val, Ey_val);
    xlabel('x'); ylabel('y');
    title('Cường độ điện trường');

    % Vẽ mật độ năng lượng điện trường
    figure(3);
    surf(X, Y, u_val);
    xlabel('x'); ylabel('y'); zlabel('Mật độ năng lượng u');
    title('Phân bố mật độ năng lượng điện trường');
    shading interp; colormap hot; colorbar;
end