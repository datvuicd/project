clear;       % Xóa tất cả biến
clc;         % Xóa cửa sổ Command Window
close all;   % Đóng tất cả các cửa sổ hình ảnh
% Khai báo biến
syms x V;
%% Vòng lặp tính toán
while true
    %% Lựa chọn
    fprintf('\n=========================================================\n');
    fprintf('     CHƯƠNG TRÌNH TÍNH CÔNG (WORK CALCULATION TOOL)     \n');
    fprintf('            VUI LÒNG CHỌN TRƯỜNG HỢP TÍNH TOÁN             \n');
    fprintf('=========================================================\n');
    fprintf('  [1]  Trường hợp 1: Lực là hằng số (W = F * d)\n');
    fprintf('  [2]  Trường hợp 2: Lực biến thiên (Tự nhập hàm f(x) bất kỳ)\n');
    fprintf('  [3]  Trường hợp 3: Ước tính công từ giá trị rời rạc (Bảng giá trị)\n'); 
    fprintf('  [4]  Trường hợp 4: Ứng dụng vật lý (Giãn nở khí PV^gamma = k)\n');
    fprintf('  [5]  Trường hợp 5: Ứng dụng vật lý (Lực hấp dẫn Newton)\n');
    fprintf('---------------------------------------------------------\n');
    fprintf('  [0]  Thoát chương trình\n');
    
    choice_str = input('\nNhập lựa chọn của bạn (0-5): ', 's');
    
    % Thoát vòng lặp
    if strcmp(choice_str, '0') || isempty(choice_str)
        fprintf('\nĐã thoát chương trình. Tạm biệt!\n');
        break;
    end % Thoát chương trình
    
    % Chuyển lựa chọn sang dạng số
    choice = str2double(choice_str);
    
    %% Xử lý lựa chọn
    clc; % Xóa các tác vụ để hiển thị kết quả rõ ràng
    switch choice
        case 1
            %% Trường hợp 1: Lực không đổi
            fprintf('## TRƯỜNG HỢP 1: Lực không đổi ##\n');
            F = input('Nhập lực không đổi F (đơn vị: lb): ');
            d = input('Nhập quãng đường d (đơn vị: ft): ');
            W = F * d;
            fprintf('=> Công (W) = F * d = %.2f * %.2f = %.2f ft-lb\n', F, d, W);
            
        case 2
            %% TRƯỜNG HỢP 2: Lực biến thiên
            fprintf('## TRƯỜNG HỢP 2: Lực biến thiên (Người dùng tự nhập hàm) ##\n');
            % Nhập hàm
            F_str = input('Nhập hàm lực F(x) (sử dụng ''x'' làm biến, ví dụ: 10/(1+x)^2): ', 's');
            
            if isempty(F_str)
                fprintf('Lỗi: Không nhận thấy hàm. Quay về menu.\n');
                continue; % Quay lại vòng lặp while
            end
            
            % Chuyển chuỗi thành hàm symbolic
            try
                F_func = str2sym(F_str);
            catch ME
                fprintf('Lỗi khi biên dịch hàm: %s\n', ME.message);
                fprintf('Vui lòng đảm bảo bạn nhập hàm đúng cú pháp MATLAB (ví dụ: 10*x, sin(x), x^2).\n');
                continue; % Quay lại vòng lặp while chính
            end
            
            a = input('Nhập điểm bắt đầu (a) (ví dụ: 0): ');
            b = input('Nhập điểm kết thúc (b) (ví dụ: 9): ');
            
            % Tính tích phân
            try
                W_calc = int(F_func, x, a, b);
            
                fprintf('Hàm lực đã nhập: F(x) = %s\n', char(F_func));
                fprintf('Di chuyển từ x = %.1f đến x = %.1f\n', a, b);
                fprintf('=> Công (W) = Tích phân của F(x) = %g (đơn vị)\n', double(W_calc));
            catch ME_int
                fprintf('Lỗi khi tính tích phân: %s\n', ME_int.message);
                fprintf('Có thể hàm không liên tục hoặc có lỗi cú pháp.\n');
            end
            
        case 3
            %% TRƯỜNG HỢP 3: Ước tính công từ dữ liệu 
            fprintf('## TRƯỜNG HỢP 3: Ước tính công từ dữ liệu ##\n');
            fprintf('Đây là trường hợp lực được cho bởi bảng dữ liệu rời rạc.\n');
            fprintf('Vui lòng chọn phương pháp xấp xỉ tích phân:\n');
            fprintf('  [1] Quy tắc Điểm giữa (Midpoint Rule) - (Chỉ nhập điểm giữa)\n');
            fprintf('  [2] Quy tắc Hình thang (Trapezoidal Rule) - (Nhập tất cả điểm)\n');
            method_choice = input('Nhập lựa chọn (1 hoặc 2): ');
            
            if method_choice == 1
                fprintf('\n--- Phương pháp: Quy tắc Điểm giữa ---\n');
                delta_x = input('Nhập bề rộng mỗi khoảng (delta_x) (ví dụ: 4): ');
                mid_vals_str = input('Nhập các giá trị f(x) tại điểm giữa, đặt trong ngoặc vuông (ví dụ: [5.8 8.8 8.2 5.2]): ', 's');
                midpoint_values = str2double(mid_vals_str); 
                W_midpoint = delta_x * sum(midpoint_values);
                fprintf('=> Công (W) ~ Delta_x * Sum(f(midpoints)) = %.2f J\n', W_midpoint);
                
            elseif method_choice == 2
                fprintf('\n--- Phương pháp: Quy tắc Hình thang (hàm trapz) ---\n');
                fprintf('Nhập toàn bộ dữ liệu từ bảng:\n');
                x_str = input('Nhập các giá trị x, đặt trong ngoặc vuông (ví dụ: [4 6 8 10 12 14 16 18 20]): ', 's');
                f_str = input('Nhập các giá trị f(x) tương ứng (ví dụ: [5 5.8 7.0 8.8 9.6 8.2 6.7 5.2 4.1]): ', 's');
                x_vals = str2double(x_str); 
                f_vals = str2double(f_str); 
                
                if length(x_vals) ~= length(f_vals)
                    fprintf('Lỗi: Số lượng x và f(x) phải bằng nhau.\n');
                else
                    W_trapezoid = trapz(x_vals, f_vals);
                    fprintf('=> Công (W) ~ trapz(x, f(x)) = %.2f J\n', W_trapezoid);
                end
            else
                fprintf('Lựa chọn không hợp lệ.\n');
            end
        case 4
            %% TRƯỜNG HỢP 4: Ứng dụng (Giãn nở khí - Bài 28)
            fprintf('## TRƯỜNG HỢP 4: Ứng dụng (Giãn nở khí) ##\n');
            fprintf('Tính công W = Tích phân(P dV) với P * V^gamma = k\n');
            P1 = input('Nhập áp suất P1 (ví dụ: 160 lb/in^2): ');
            V1 = input('Nhập thể tích V1 (ví dụ: 100 in^3): ');
            V2 = input('Nhập thể tích V2 (ví dụ: 800 in^3): ');
            gamma = input('Nhập hằng số đoạn nhiệt gamma (ví dụ: 1.4): ');
            
            k = P1 * V1^gamma;
            P = k / V^gamma;
            W_calc = int(P, V, V1, V2);
            
            fprintf('Hằng số k = P1 * V1^%.1f = %e\n', gamma, k);
            fprintf('Công (W) = Tích phân của P(V) từ V1=%.0f đến V2=%.0f\n', V1, V2);
            fprintf('=> Công (W) = %.2f in-lb\n', double(W_calc));
            
        case 5
            %% TRƯỜNG HỢP 5: Ứng dụng (Lực hấp dẫn - Bài 30)
            fprintf('## TRƯỜNG HỢP 5: Ứng dụng (Lực hấp dẫn Newton) ##\n');
            fprintf('Tính công để thắng lực hấp dẫn F(x) = G*M*m / x^2\n');
            G = 6.67e-11; % Hằng số G
            M = 5.98e24;  % Khối lượng Trái Đất
            R = 6.37e6;   % Bán kính Trái Đất
            
            fprintf('Sử dụng các hằng số: G=%.2e, M=%.2e, R=%.2e (m)\n', G, M, R);
            
            m = input('Nhập khối lượng vệ tinh (m) (kg, ví dụ: 1000): ');
            h_km = input('Nhập độ cao quỹ đạo (h) (km, ví dụ: 1000): ');
            h = h_km * 1000; % Đổi sang mét
            
            x1 = R; % Điểm bắt đầu (mặt đất)
            x2 = R + h; % Điểm kết thúc (quỹ đạo)
            F_grav = (G * M * m) / x^2;
            
            W_calc = int(F_grav, x, x1, x2);
            
            fprintf('Di chuyển từ x1 (mặt đất) = %.2e m\n', x1);
            fprintf('Đến x2 (quỹ đạo) = %.2e m\n', x2);
            fprintf('=> Công (W) = Tích phân của F(x) = %.4e J\n', double(W_calc));
            fprintf('(Tương đương %.4f Giga-Joules (GJ))\n', double(W_calc)/1e9);
        otherwise
            fprintf('Lựa chọn không hợp lệ. Vui lòng chọn một số từ 0 đến 5.\n');
            
    end % Kết thúc switch
    
    % Tạm dừng để người dùng đọc kết quả
    input('\nNhấn [Enter] để quay về menu chính...');
    clc;
    
end % Kết thúc while