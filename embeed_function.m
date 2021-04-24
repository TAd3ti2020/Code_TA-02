function [Sn,Un,Vn] = embeed_function(voice_frame, Gambar) 


%Fungsi DCT 
DCT = dct(voice_frame); 
A = zeros(4,4);   %zeros : ukuran matriks
temp = 1;
for i = 1 : 4
    for j = 1 : 4
        A(i,j) = DCT(1, temp);
        temp = temp + 1;           
    end    
end    

%Fungsi SVD
[U,S,V] = svd(A);

%Embeed Watermark
B = [];  %matriks kosong
temp = 1;
for i = 1 : length(Gambar(:,1))   %baris
    for j = 1 : length(Gambar(1,:)) %kolom
        B(temp) = Gambar(i,j);   %i = baris, j = kolom
        temp = temp + 1; 
    end
end
index_b = 1;  %untuk bit
W = zeros(4,4);
for i = 1 : 4
    for j = 1 : 4
        if i == j
            index_b = index_b + 1;
        else
            W(i,j) = B (index_b); 
            index_b = index_b + 1;
        end
    end
end

alpha = 0.000000001;
Sn = A + W*alpha; % hasil Embeed
[Un,Sn,Vn] = svd(Sn); %SVD Sn

%Invers SVD
invers_Sn = Un*Sn*Vn';

%Invers DCT
invers_dct_Sn = idct(invers_Sn);   %mengembalikan Sn ke awal
Sn = [];
temp = 1;
for i = 1 : 4
    for j = 1 : 4
        Sn(temp) = invers_dct_Sn(i,j);
        temp = temp + 1;
    end
end    
Sn = Sn;