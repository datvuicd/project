function dstt
    clear; close all; clc;

    % --- PHẦN 1: CHỌN FILE VÀ ĐỌC DỮ LIỆU ---
    fprintf('=== CHUONG TRINH GOI Y SACH (SVD) ===\n');
    fprintf('Buoc 1: Vui long chon file Excel du lieu...\n');
    [file, path] = uigetfile({'*.xlsx';'*.csv'}, 'Chon file Excel');
    
    if isequal(file, 0)
        disp('Da huy chon file.'); return; 
    end
    
    fullpath = fullfile(path, file);
    
    % Đọc file
    raw_table = readtable(fullpath, 'VariableNamingRule', 'preserve');
    
    % Tự động nhận diện dữ liệu
    reader_names = string(raw_table{:, 2}); % Cột 2: Tên người
    book_names = raw_table.Properties.VariableNames(3:end); % Cột 3+: Tên sách
    book_evaluate = raw_table{:, 3:end}; % Dữ liệu điểm
    book_evaluate(isnan(book_evaluate)) = 0; 

    %HIỂN THỊ DỮ LIỆU GỐC
    disp('--------------------------------------------------');
    disp('1. Ma tran danh gia muc do hay cua sach (Du lieu goc):');
    disp(book_evaluate);

    %PHẦN 2: PHÂN TÍCH SVD
    [U, S, V] = svd(book_evaluate, 'econ');
    
    % Tự động tính k (giữ 90% thông tin)
    total_energy = sum(diag(S));
    k = find(cumsum(diag(S))/total_energy >= 0.90, 1);
    if isempty(k), k=3; end 

    U_k = U(:, 1:k);
    S_k = S(1:k, 1:k);
    V_k = V(:, 1:k);

    %HIỂN THỊ CÁC MA TRẬN TRUNG GIAN
    disp('--------------------------------------------------');
    disp('2. Ket qua phan ra SVD:');
    disp('Ma tran U (yeu to nguoi doc):'); disp(U);
    disp('Ma tran S (gia tri dac trung):'); disp(S);
    disp('Ma tran V (yeu to san pham):'); disp(V);
    
    fprintf('--------------------------------------------------\n');
    fprintf('3. Giam chieu du lieu (k = %d):\n', k);
    disp('Ma tran U_k:'); disp(U_k);
    disp('Ma tran S_k:'); disp(S_k);
    disp('Ma tran V_k:'); disp(V_k);

    %DỰ ĐOÁN
    predicted_ratings = U_k * S_k * V_k';
    disp('--------------------------------------------------');
    disp('4. Ma tran du doan (Predicted Ratings):');
    disp(predicted_ratings);

    %GỢI Ý CHO NGƯỜI CŨ
    fprintf('--------------------------------------------------\n');
    fprintf('5. DANH SACH GOI Y CHO CAC NGUOI DUNG CU:\n');
    
    for i = 1:size(predicted_ratings, 1)
        [~, Book_indices] = sort(predicted_ratings(i, :), 'descend');
        current_name = reader_names(i);
        
        % Tạo chuỗi tên sách
        list_sach = "";
        for j = 1:length(Book_indices)
            idx = Book_indices(j);
            if j == 1
                list_sach = string(book_names{idx});
            else
                list_sach = list_sach + ", " + string(book_names{idx});
            end
        end
        fprintf('   - %s: %s\n', current_name, list_sach);
    end

    %PHẦN 3: NHẬP LIỆU NGƯỜI MỚI
    fprintf('\n==================================================\n');
    fprintf('BUOC 2: DANH GIA CUA BAN (NGUOI DUNG MOI)\n');
    fprintf('Hay nhap diem tu 0 den 5 (0 la chua doc).\n');
    
    new_book_evaluate = zeros(1, length(book_names));
    
    for i = 1:length(book_names)
        while true
            % Vòng lặp kiểm tra lỗi nhập liệu
            prompt = sprintf('   > Diem cho "%s": ', book_names{i});
            val = input(prompt);
            
            if isempty(val)
                val = 0; break;
            elseif isnumeric(val) && val >= 0 && val <= 5
                break;
            else
                fprintf('     [!] Loi: Chi duoc nhap so tu 0 den 5. Nhap lai!\n');
            end
        end
        new_book_evaluate(i) = val;
    end

    %TÍNH TOÁN NGƯỜI GIỐNG NHẤT
    new_book_evaluate_in_Uk = new_book_evaluate * V_k;

    similarity = zeros(size(U_k, 1), 1);
    for i = 1:size(U_k, 1)
        tu_so = dot(new_book_evaluate_in_Uk, U_k(i, :));
        mau_so = norm(new_book_evaluate_in_Uk) * norm(U_k(i, :));
        if mau_so == 0, similarity(i) = 0; else, similarity(i) = tu_so / mau_so; end
    end

    [max_sim, most_similar_idx] = max(similarity);
    similar_person_name = reader_names(most_similar_idx);

    fprintf('\n--------------------------------------------------\n');
    if max(similarity) == 0
        fprintf('KET QUA: Du lieu cua ban chua du de tim nguoi giong nhat.\n');
        % Lấy trung bình cộng nếu không tìm thấy ai giống
        recommended_scores = mean(predicted_ratings, 1); 
    else
        fprintf('KET QUA: Gu doc sach cua ban giong nhat voi "%s" (Do giong: %.2f%%)\n', ...
            similar_person_name, max_sim*100);
        recommended_scores = predicted_ratings(most_similar_idx, :);
    end

    % --- HIỂN THỊ GỢI Ý CHO BẠN ---
    % Lọc bỏ sách đã đọc
    recommended_scores(new_book_evaluate > 0) = -999;

    [sorted_scores, sorted_idx] = sort(recommended_scores, 'descend');

    fprintf('\n>>> CAC SACH GOI Y CHO BAN (Theo thu tu uu tien) <<<\n');
    
    count = 0;
    for i = 1:length(sorted_idx)
        idx = sorted_idx(i);
        score = sorted_scores(i);
        
        % Hiện tất cả sách chưa đọc (kể cả điểm dự đoán thấp)
        if score > -100 
            count = count + 1;
            fprintf('%d. %s (Diem du doan: %.2f)\n', count, book_names{idx}, score);
        end
    end
    
    if count == 0
        fprintf('Khong co goi y nao (Ban da doc het cac sach).\n');
    end
end