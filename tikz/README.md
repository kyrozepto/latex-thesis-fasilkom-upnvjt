# tikz/ — sumber gambar vektor

Folder ini berisi gambar TikZ/pgfplots yang **dirender lebih dahulu** menjadi PDF di `figures/`,
bukan digambar langsung di dalam naskah.

## Kenapa dipisah

- **Kompilasi naskah tetap cepat.** Satu gambar pgfplots dengan ribuan titik bisa memakan puluhan
  detik. Kalau digambar di dalam naskah, biaya itu dibayar ulang setiap kali Anda menjalankan
  `build proposal` — empat kali per build.
- **Gambar bisa diperiksa sendiri.** Anda dapat membangun satu gambar saja dan melihat hasilnya
  tanpa menunggu seluruh naskah selesai.
- **Kesalahan mudah dilacak.** Galat TikZ muncul di log gambar itu sendiri, bukan tenggelam di
  antara ratusan baris log naskah.

Gambar yang bukan hasil TikZ (foto, tangkapan layar, keluaran skrip Python) tidak perlu lewat sini:
letakkan langsung di `figures/`.

## Cara menambah gambar

1. Buat berkas baru, misalnya `tikz/ch3-arsitektur.tex`:

   ```latex
   \documentclass[border=2pt]{standalone}
   \input{preamble}

   \begin{document}
   \begin{tikzpicture}
     % ...
   \end{tikzpicture}
   \end{document}
   ```

2. Render:

   ```
   cd tikz
   build ch3-arsitektur          REM Windows
   bash build.sh ch3-arsitektur  # Linux, macOS, WSL
   ```

   Tanpa argumen, seluruh berkas `.tex` di folder ini dibangun ulang. `preamble.tex` dilewati karena
   ia bukan gambar, melainkan berkas yang di-`\input` gambar lain.

3. Panggil dari naskah. `\graphicspath{{figures/}}` sudah diatur, jadi cukup nama berkasnya:

   ```latex
   \begin{figure}[H]
     \centering
     \includegraphics[width=0.9\linewidth]{ch3-arsitektur.pdf}
     \caption{Arsitektur sistem yang diusulkan.}
     \label{fig:arsitektur}
   \end{figure}
   ```

## `preamble.tex`

Berkas ini memuat font dan gaya bersama seluruh gambar:

- **Font `newtxtext`/`newtxmath`**, sama dengan `template.cls`. Tanpa ini, angka pada sumbu grafik
  terlihat berbeda dari angka pada paragraf di sebelahnya.
- **Warna**: `aksen` (biru), `aksendua` (jingga gelap), `netral` (abu-abu).
- **Gaya diagram alur**: `tahap`, `tahapaksen`, `panah`, `panahaksen`, `kelompok`.
- **Gaya grafik**: `bakuaxis` untuk sumbu, `bakubar` untuk diagram batang.
- **Pembantu**: `\panellabel{axis}{(a)}` dan `\keteranganbersama{axis1}{axis2}{teks}`.

Ubah `preamble.tex` bila Anda ingin mengganti warna atau tebal garis di semua gambar sekaligus.

## Catatan

- Setelah `build.sh`/`build.bat` selesai, `figures/` hanya berisi `.pdf`; berkas `.aux` dan `.log`
  hasil antara dihapus otomatis.
- PDF hasil render **tidak** diabaikan `.gitignore` — commit saja, supaya orang lain bisa
  membangun naskah tanpa harus menjalankan pipeline ini lebih dahulu.
- `example-diagram.tex` adalah contoh yang bisa Anda hapus setelah punya gambar sendiri.
