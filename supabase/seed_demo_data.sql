-- TesbihYol — Demo/tanıtım verisi: 6 satıcı + ~44 ürün, gerçek görsellerle
-- SQL Editor'de, migration_v7.sql'den SONRA çalıştırın.
--
-- ÖNEMLİ: Bu betik demo/tanıtım amaçlıdır. Satıcı hesapları için auth.users
-- tablosuna doğrudan satır eklenir (normalde bu tabloya sadece Supabase Auth
-- üzerinden, kayıt akışıyla satır eklenir). Bu hesaplarla gerçekten giriş
-- yapılması beklenmiyor — sadece ürün/vitrin verisini var eden sahiplik
-- ilişkisini kurmak için var. Ürün görselleri Wikimedia Commons'tan (özgürce
-- kullanılabilir, gerçek) fotoğraflardır; bazı malzemeler için birebir eşleşen
-- fotoğraf bulunamadığında o malzemeye en yakın gerçek taş/tahta/tesbih
-- fotoğrafı kullanılmıştır.
--
-- Geri almak isterseniz: sadece bu betikle eklenen satıcıları silmek yeterli
-- (products/profiles cascade ile birlikte silinir):
--   delete from auth.users where email like '%@tesbihyol-demo.com';

-- ==================== 1) SATICI HESAPLARI (auth.users) ====================

insert into auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
  confirmation_token, email_change, email_change_token_new, recovery_token
) values
  ('00000000-0000-0000-0000-000000000000', 'a1a1a1a1-0001-4000-8000-000000000001', 'authenticated', 'authenticated',
   'konyatesbihevi@tesbihyol-demo.com', crypt('TesbihYolDemo2026!', gen_salt('bf')), now(),
   '{"provider":"email","providers":["email"]}', '{"full_name":"Mustafa Kaya"}', now(), now(), '', '', '', ''),
  ('00000000-0000-0000-0000-000000000000', 'a1a1a1a1-0002-4000-8000-000000000002', 'authenticated', 'authenticated',
   'erzurumoltu@tesbihyol-demo.com', crypt('TesbihYolDemo2026!', gen_salt('bf')), now(),
   '{"provider":"email","providers":["email"]}', '{"full_name":"Recep Demir"}', now(), now(), '', '', '', ''),
  ('00000000-0000-0000-0000-000000000000', 'a1a1a1a1-0003-4000-8000-000000000003', 'authenticated', 'authenticated',
   'istanbulgumus@tesbihyol-demo.com', crypt('TesbihYolDemo2026!', gen_salt('bf')), now(),
   '{"provider":"email","providers":["email"]}', '{"full_name":"Elif Arslan"}', now(), now(), '', '', '', ''),
  ('00000000-0000-0000-0000-000000000000', 'a1a1a1a1-0004-4000-8000-000000000004', 'authenticated', 'authenticated',
   'trabzondogaltas@tesbihyol-demo.com', crypt('TesbihYolDemo2026!', gen_salt('bf')), now(),
   '{"provider":"email","providers":["email"]}', '{"full_name":"Zeynep Çelik"}', now(), now(), '', '', '', ''),
  ('00000000-0000-0000-0000-000000000000', 'a1a1a1a1-0005-4000-8000-000000000005', 'authenticated', 'authenticated',
   'bursaahsap@tesbihyol-demo.com', crypt('TesbihYolDemo2026!', gen_salt('bf')), now(),
   '{"provider":"email","providers":["email"]}', '{"full_name":"Hasan Yıldız"}', now(), now(), '', '', '', ''),
  ('00000000-0000-0000-0000-000000000000', 'a1a1a1a1-0006-4000-8000-000000000006', 'authenticated', 'authenticated',
   'kapadokyamucevher@tesbihyol-demo.com', crypt('TesbihYolDemo2026!', gen_salt('bf')), now(),
   '{"provider":"email","providers":["email"]}', '{"full_name":"Ayşe Korkmaz"}', now(), now(), '', '', '', '')
on conflict (id) do nothing;

-- ==================== 2) SATICI PROFİLLERİ (sellers) ====================

insert into public.sellers (id, user_id, store_name, owner_name, phone, tc_no, birth_date, business_type, category_pref, iban, bank_name, bio, status, created_at) values
  ('b2b2b2b2-0001-4000-8000-000000000001', 'a1a1a1a1-0001-4000-8000-000000000001', 'Konya Tesbih Evi', 'Mustafa Kaya', '05321112233', '11111111110', '1978-03-14', 'sahis', 'Tesbih',
   'TR330006100519786457841326', 'Ziraat Bankası', 'Konya''da üç kuşaktır kehribar ve sedef tesbih işleyen bir aile atölyesiyiz. Her boncuk elde şekillendirilir, cilası doğal yöntemlerle yapılır.', 'approved', now() - interval '210 days'),
  ('b2b2b2b2-0002-4000-8000-000000000002', 'a1a1a1a1-0002-4000-8000-000000000002', 'Erzurum Oltu Sanatları', 'Recep Demir', '05332223344', '22222222220', '1982-07-02', 'sahis', 'Tesbih',
   'TR330006100519786457841327', 'İş Bankası', 'Erzurum''un yerel taşı oltu ile 20 yılı aşkın süredir tesbih işçiliği yapıyoruz. Her parça atölyemizde elle tornalanır.', 'approved', now() - interval '180 days'),
  ('b2b2b2b2-0003-4000-8000-000000000003', 'a1a1a1a1-0003-4000-8000-000000000003', 'İstanbul Gümüş Atölyesi', 'Elif Arslan', '05343334455', '33333333330', '1990-11-20', 'sahis', 'Yüzük',
   'TR330006100519786457841328', 'Garanti BBVA', 'Kapalıçarşı geleneğinden gelen 925 ayar gümüş yüzük ve tesbih detayları üretiyoruz. Her parça damgalı ve ayar garantilidir.', 'approved', now() - interval '150 days'),
  ('b2b2b2b2-0004-4000-8000-000000000004', 'a1a1a1a1-0004-4000-8000-000000000004', 'Trabzon Doğal Taş & Takı', 'Zeynep Çelik', '05354445566', '44444444440', '1985-05-09', 'sahis', 'Yüzük',
   'TR330006100519786457841329', 'Akbank', 'Akik, kaplan gözü, firuze ve oniks gibi doğal taşlarla hem tesbih hem yüzük üretiyoruz. Taşlarımız sertifikalı tedarikçilerden temin edilir.', 'approved', now() - interval '120 days'),
  ('b2b2b2b2-0005-4000-8000-000000000005', 'a1a1a1a1-0005-4000-8000-000000000005', 'Bursa Ahşap Atölyesi', 'Hasan Yıldız', '05365556677', '55555555550', '1975-01-25', 'sahis', 'Tesbih',
   'TR330006100519786457841330', 'Yapı Kredi', 'Sandal ağacı, ceviz ve zeytin ağacından, tamamen doğal yağlarla cilalanmış tesbihler üretiyoruz. Ahşap işçiliğimiz Bursa''nın geleneksel oymacılık ustalarından miras.', 'approved', now() - interval '95 days'),
  ('b2b2b2b2-0006-4000-8000-000000000006', 'a1a1a1a1-0006-4000-8000-000000000006', 'Kapadokya Mücevher', 'Ayşe Korkmaz', '05376667788', '66666666660', '1988-09-30', 'sahis', 'Yüzük',
   'TR330006100519786457841331', 'Denizbank', 'Zümrüt, yakut ve 22 ayar altın kaplamalı yüzük tasarımları yapıyoruz. Nevşehir''deki atölyemizde her taş elle yuvalanır.', 'approved', now() - interval '60 days')
on conflict (id) do nothing;

-- ==================== 3) ÜRÜNLER (products) ====================
-- Görseller: upload.wikimedia.org (özgür lisanslı gerçek fotoğraflar). İlk
-- görsel = kapak (image_url), tüm liste = detay sayfası galerisi (images).

insert into public.products
  (seller_id, name, category, material, description, price, stock, size_info, weight_grams, shipping_option, shipping_fee, image_url, images, featured, status, created_at)
values

-- ---- KONYA TESBİH EVİ: Kehribar + Sedef ----
('b2b2b2b2-0001-4000-8000-000000000001', 'Sultani Kehribar Tesbih', 'Tesbih', 'Kehribar',
 'Baltık kehribarından elde, 33''lü sultani boy olarak tornalanmıştır. Her boncuk kendi içinde hafif renk ve doku farkı taşır — bu, doğal kehribarın en belirgin işaretidir. Kullandıkça avuç içi sıcaklığıyla parlaklığı artar, yıllar içinde koyulaşarak kendine özgü bir patina kazanır. İmame ve tepelik gümüş kaplamadır, püskül el yapımı ipek sırmadır.',
 1450.00, 6, '33''lü, Sultani Boy', 32, 'ucretsiz', 0,
 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/41/020240302_Amber_muslim_prayer_beads.jpg/800px-020240302_Amber_muslim_prayer_beads.jpg',
 ARRAY[
   'https://upload.wikimedia.org/wikipedia/commons/thumb/4/41/020240302_Amber_muslim_prayer_beads.jpg/800px-020240302_Amber_muslim_prayer_beads.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/7/72/Amber_Bead_-_YDEA_-_73871.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/8/89/Amber_Bead_-_YDEA_-_73872.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/8/85/Amber_Bead_-_YDEA_-_73873.jpg'
 ], true, 'published', now() - interval '40 days'),

('b2b2b2b2-0001-4000-8000-000000000001', 'Basra Kesim Kehribar Tesbih', 'Tesbih', 'Kehribar',
 'Basra kesimi (çokgen yüzeyli) kehribar boncuklardan 99''lu olarak hazırlanmıştır. Yüzeylerdeki keskin kesim ışığı farklı açılardan yansıtır, elde tutuşu daha "kavramalı" hale getirir. Zikir çekerken boncuklar arasında net bir ayrım hissedilir. Hediye kutusu ve bakım bezi ile birlikte gönderilir.',
 1890.00, 4, '99''lu, Basra Kesim', 41, 'ucretsiz', 0,
 'https://upload.wikimedia.org/wikipedia/commons/6/6f/Amber_Bead_-_YDEA_-_73870.jpg',
 ARRAY[
   'https://upload.wikimedia.org/wikipedia/commons/6/6f/Amber_Bead_-_YDEA_-_73870.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/7/72/Amber_Bead_-_YDEA_-_73871.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8a/Gold_necklace_with_inlaid_amber_MET_19473.jpg/800px-Gold_necklace_with_inlaid_amber_MET_19473.jpg'
 ], false, 'published', now() - interval '8 days'),

('b2b2b2b2-0001-4000-8000-000000000001', 'Zümrüt Yeşili Sedef Tesbih', 'Tesbih', 'Sedef',
 'Doğal sedefin ince dilimlenip yeşil tonlarla katmanlandığı 33''lü bir tesbihtir. Sedef, ışığı yakaladığı açıya göre gri-yeşil-mor arası renk oyunu (nakır efekti) gösterir; bu yüzden hiçbir boncuk birbirinin aynısı değildir. Hafif yapısı sayesinde uzun süre elde taşımak yormaz.',
 980.00, 8, '33''lü', 26, 'ucretsiz', 0,
 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f0/Ian_Rosenberg_Jeweller_%E2%80%93_Blue-toned_mother_of_pearl_shell_necklace.JPG/800px-Ian_Rosenberg_Jeweller_%E2%80%93_Blue-toned_mother_of_pearl_shell_necklace.JPG',
 ARRAY[
   'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f0/Ian_Rosenberg_Jeweller_%E2%80%93_Blue-toned_mother_of_pearl_shell_necklace.JPG/800px-Ian_Rosenberg_Jeweller_%E2%80%93_Blue-toned_mother_of_pearl_shell_necklace.JPG',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ed/Necklace_%28AM_674266-1%29.jpg/800px-Necklace_%28AM_674266-1%29.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/2/27/Necklace_%28AM_674266-4%29.jpg/800px-Necklace_%28AM_674266-4%29.jpg'
 ], false, 'published', now() - interval '55 days'),

('b2b2b2b2-0001-4000-8000-000000000001', 'İnci Beyazı Sedef Tesbih', 'Tesbih', 'Sedef',
 'Parlak inci beyazı sedeften, 99''lu olarak dizilmiş klasik bir tesbih. Boncuklar arası ipek geçişler, tesbihin zamanla sarkmasını ve boncukların birbirine sürtünüp aşınmasını önler. Özellikle düğün, sünnet ve bayram hediyesi olarak tercih edilir.',
 1050.00, 5, '99''lu', 34, 'ucretsiz', 0,
 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9d/Necklace_%28AM_674266-2%29.jpg/800px-Necklace_%28AM_674266-2%29.jpg',
 ARRAY[
   'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9d/Necklace_%28AM_674266-2%29.jpg/800px-Necklace_%28AM_674266-2%29.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ed/Necklace_LACMA_M.89.112.1.jpg/800px-Necklace_LACMA_M.89.112.1.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f0/Ian_Rosenberg_Jeweller_%E2%80%93_Blue-toned_mother_of_pearl_shell_necklace.JPG/800px-Ian_Rosenberg_Jeweller_%E2%80%93_Blue-toned_mother_of_pearl_shell_necklace.JPG'
 ], false, 'published', now() - interval '5 days'),

-- ---- ERZURUM OLTU SANATLARI: Oltu Taşı + Akik + Kaplan Gözü ----
('b2b2b2b2-0002-4000-8000-000000000002', 'El Oyması Oltu Taşı Tesbih', 'Tesbih', 'Oltu Taşı',
 'Erzurum''a özgü siyah oltu taşından, 33''lü olarak elde tornalanmıştır. Oltu taşı hafif ve mattır; sürtününce hafif reçine kokusu bırakması taşın doğallığının işaretidir. Her boncuğun yüzeyinde ustanın el işçiliğine dair ince tornalama izleri görülebilir.',
 890.00, 7, '33''lü', 24, 'ucretsiz', 0,
 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0d/Whitby_Jet_%2841837232445%29.jpg/800px-Whitby_Jet_%2841837232445%29.jpg',
 ARRAY[
   'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0d/Whitby_Jet_%2841837232445%29.jpg/800px-Whitby_Jet_%2841837232445%29.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b6/Whitby_Jet_%2841837233025%29.jpg/800px-Whitby_Jet_%2841837233025%29.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/8/88/Jet_cross_pendant_%28FindID_95397%29.jpg'
 ], true, 'published', now() - interval '70 days'),

('b2b2b2b2-0002-4000-8000-000000000002', 'Püsküllü Oltu Taşı Tesbih (99''lu)', 'Tesbih', 'Oltu Taşı',
 'Geleneksel 99''lu dizim, gümüş tepelik ve el yapımı ipek püskülle tamamlanmıştır. Oltu taşı yoğunluğu düşük olduğu için uzun tesbihlerde bile elde ağırlık hissettirmez. Cami ve ev kullanımı için ideal, günlük zikir pratiğine uygun bir seçimdir.',
 1120.00, 5, '99''lu', 37, 'ucretsiz', 0,
 'https://upload.wikimedia.org/wikipedia/commons/e/ee/Jet_cross_pendant%2C_view_from_top_%28FindID_95397%29.jpg',
 ARRAY[
   'https://upload.wikimedia.org/wikipedia/commons/e/ee/Jet_cross_pendant%2C_view_from_top_%28FindID_95397%29.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/a/a4/Jet_cross_pendant%2C_reverse_%28FindID_95397%29.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7b/Modern_jet_chain_link_%28section%29_%28FindID_289983%29.jpg/800px-Modern_jet_chain_link_%28section%29_%28FindID_289983%29.jpg'
 ], false, 'published', now() - interval '12 days'),

('b2b2b2b2-0002-4000-8000-000000000002', 'Damarlı Akik Tesbih', 'Tesbih', 'Akik',
 'Doğal akik taşının karakteristik damar desenleri her boncukta farklı bir görüntü oluşturur. 33''lü olarak dizilmiş bu tesbih, akiğin sertliği sayesinde günlük kullanımda çizilmeye karşı oldukça dayanıklıdır. Soğuk dokunuşu ve yarı saydam yapısı akiği diğer taşlardan ayırır.',
 760.00, 9, '33''lü', 29, 'ucretsiz', 0,
 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/26/Malawi_Agate_%28Malawi%2C_southeastern_Africa%29_%2832734668126%29.jpg/800px-Malawi_Agate_%28Malawi%2C_southeastern_Africa%29_%2832734668126%29.jpg',
 ARRAY[
   'https://upload.wikimedia.org/wikipedia/commons/thumb/2/26/Malawi_Agate_%28Malawi%2C_southeastern_Africa%29_%2832734668126%29.jpg/800px-Malawi_Agate_%28Malawi%2C_southeastern_Africa%29_%2832734668126%29.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d9/Modern_white_metal_and_layered_chalcedony_hinged_bracelet_%28FindID_1017837%29.jpg/800px-Modern_white_metal_and_layered_chalcedony_hinged_bracelet_%28FindID_1017837%29.jpg'
 ], false, 'published', now() - interval '30 days'),

('b2b2b2b2-0002-4000-8000-000000000002', 'Kaplan Gözü Doğal Taş Tesbih', 'Tesbih', 'Kaplan Gözü',
 'Altın-kahve tonlarında ışıltı (kedigözü etkisi) veren kaplan gözü taşından 33''lü tesbih. Taş, ışık kaynağına göre yüzeyinde hareket eden bir parlaklık çizgisi gösterir — bu optik etki taşın doğal kristal yapısından kaynaklanır ve her açıdan farklı görünür.',
 820.00, 6, '33''lü', 27, 'ucretsiz', 0,
 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/be/Tiger%27s_eye.jpg/800px-Tiger%27s_eye.jpg',
 ARRAY[
   'https://upload.wikimedia.org/wikipedia/commons/thumb/b/be/Tiger%27s_eye.jpg/800px-Tiger%27s_eye.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/2/26/Malawi_Agate_%28Malawi%2C_southeastern_Africa%29_%2832734668126%29.jpg/800px-Malawi_Agate_%28Malawi%2C_southeastern_Africa%29_%2832734668126%29.jpg'
 ], false, 'published', now() - interval '3 days'),

-- ---- İSTANBUL GÜMÜŞ ATÖLYESİ: Gümüş tesbih + Gümüş/Altın/Sade yüzük ----
('b2b2b2b2-0003-4000-8000-000000000003', 'Gümüş Detaylı Klasik Tesbih', 'Tesbih', 'Gümüş',
 'İmame, tepelik ve aralık parçaları 925 ayar gümüşten el işçiliğiyle üretilmiştir. Boncuklar sade, mat dokuludur; asıl detay gümüş aksamın üzerindeki motiflerdedir. Zamanla oluşan hafif kararma, gümüşün doğal karakteridir ve kadife bezle kolayca giderilebilir.',
 1650.00, 4, '33''lü', 30, 'ucretsiz', 0,
 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cf/Tasbih_or_prayer_beads.jpg/800px-Tasbih_or_prayer_beads.jpg',
 ARRAY[
   'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cf/Tasbih_or_prayer_beads.jpg/800px-Tasbih_or_prayer_beads.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/Qur%27an_and_tespih.jpg/800px-Qur%27an_and_tespih.jpg'
 ], false, 'published', now() - interval '22 days'),

('b2b2b2b2-0003-4000-8000-000000000003', 'Zirkon Taşlı Gümüş Yüzük', 'Yüzük', 'Gümüş 925',
 '925 ayar gümüş üzerine tek taş zirkon işlenmiş, günlük kullanıma uygun bir yüzük. Yüzeyi el cilası ile parlatılmıştır, taş yuvası sağlam bir pençe kapama ile sabitlenmiştir. Su ile teması sorun yaratmaz, ancak parfüm ve kimyasallardan uzak tutulması önerilir.',
 650.00, 10, '18-24 numara arası ölçülendirilebilir', 6.5, 'alici', 45,
 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Flat_silver_ring_with_a_triangular_faceted_garnet_1.jpg/800px-Flat_silver_ring_with_a_triangular_faceted_garnet_1.jpg',
 ARRAY[
   'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Flat_silver_ring_with_a_triangular_faceted_garnet_1.jpg/800px-Flat_silver_ring_with_a_triangular_faceted_garnet_1.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/8/80/Flat_silver_ring_with_a_triangular_faceted_garnet_2.jpg/800px-Flat_silver_ring_with_a_triangular_faceted_garnet_2.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/4/46/Flat_silver_ring_with_a_triangular_faceted_garnet_3.jpg/800px-Flat_silver_ring_with_a_triangular_faceted_garnet_3.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b9/Flat_silver_ring_with_a_triangular_faceted_garnet_4.jpg/800px-Flat_silver_ring_with_a_triangular_faceted_garnet_4.jpg'
 ], true, 'published', now() - interval '18 days'),

('b2b2b2b2-0003-4000-8000-000000000003', 'Sade Gümüş Alyans Model Yüzük', 'Yüzük', 'Sade',
 'Taşsız, düz yüzeyli 925 ayar gümüş yüzük. İç yüzeyi pürüzsüz işlenmiştir, günlük kullanımda tahriş yapmaz. Sadeliği sayesinde hem tek başına hem de başka yüzüklerle kombinlenerek kullanılabilir.',
 420.00, 15, '16-22 numara arası', 4.2, 'ucretsiz', 0,
 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/17/Silver_ring_and_scorzoneras_by_ASQ.jpg/800px-Silver_ring_and_scorzoneras_by_ASQ.jpg',
 ARRAY[
   'https://upload.wikimedia.org/wikipedia/commons/thumb/1/17/Silver_ring_and_scorzoneras_by_ASQ.jpg/800px-Silver_ring_and_scorzoneras_by_ASQ.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/7/77/Silver_ring_and_spaghetti_by_ASQ.jpg/800px-Silver_ring_and_spaghetti_by_ASQ.jpg'
 ], false, 'published', now() - interval '65 days'),

('b2b2b2b2-0003-4000-8000-000000000003', '14 Ayar Altın Kaplama İnce Yüzük', 'Yüzük', 'Altın',
 'Gümüş alt yapı üzerine 14 ayar altın kaplama uygulanmış ince tasarım bir yüzük. Kaplama kalınlığı standart uygulamaların üzerinde tutularak solma süresi uzatılmıştır. Günlük kullanımda su ile teması sakıncalı değildir.',
 890.00, 8, '16-22 numara arası', 3.8, 'ucretsiz', 0,
 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/df/Gold_wedding_ring.jpg/800px-Gold_wedding_ring.jpg',
 ARRAY[
   'https://upload.wikimedia.org/wikipedia/commons/thumb/d/df/Gold_wedding_ring.jpg/800px-Gold_wedding_ring.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/1/1a/Undated_plain_gold_band_or_finger_ring_%28FindID_176128%29.jpg'
 ], false, 'published', now() - interval '9 days'),

('b2b2b2b2-0003-4000-8000-000000000003', 'Oval Kesim Oniks Taşlı Gümüş Yüzük', 'Yüzük', 'Oniks',
 'Simetrik oval kesimli siyah oniks taşı, 925 ayar gümüş yuvaya oturtulmuştur. Oniksin mat-parlak dengesi, yüzüğü hem gündüz hem gece kombinlerine uygun hale getirir. Erkek ve kadın kullanımına uygun nötr bir tasarımdır.',
 720.00, 7, '17-23 numara arası', 7.1, 'ucretsiz', 0,
 'https://upload.wikimedia.org/wikipedia/commons/e/e7/Black_onyx_and_diamonds_ring.jpg',
 ARRAY[
   'https://upload.wikimedia.org/wikipedia/commons/e/e7/Black_onyx_and_diamonds_ring.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/1/1b/Onyx_Pearls_Necklace-1200.jpg'
 ], false, 'published', now() - interval '48 days'),

-- ---- TRABZON DOĞAL TAŞ & TAKI: Akik/Kaplan Gözü/Firuze/Oniks (yüzük ağırlıklı) ----
('b2b2b2b2-0004-4000-8000-000000000004', 'Damarlı Akik Taşlı Gümüş Yüzük', 'Yüzük', 'Akik',
 'Doğal akik taşı, her parçada farklı desen oluşturacak şekilde elle seçilip yuvalanmıştır. 925 ayar gümüş çerçeve, taşın rengini öne çıkaracak şekilde ince tutulmuştur. Akiğin serinlik hissi, özellikle yaz aylarında tercih sebebidir.',
 680.00, 9, '17-24 numara arası', 6.8, 'ucretsiz', 0,
 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d9/Modern_white_metal_and_layered_chalcedony_hinged_bracelet_%28FindID_1017837%29.jpg/800px-Modern_white_metal_and_layered_chalcedony_hinged_bracelet_%28FindID_1017837%29.jpg',
 ARRAY[
   'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d9/Modern_white_metal_and_layered_chalcedony_hinged_bracelet_%28FindID_1017837%29.jpg/800px-Modern_white_metal_and_layered_chalcedony_hinged_bracelet_%28FindID_1017837%29.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/2/26/Malawi_Agate_%28Malawi%2C_southeastern_Africa%29_%2832734668126%29.jpg/800px-Malawi_Agate_%28Malawi%2C_southeastern_Africa%29_%2832734668126%29.jpg'
 ], false, 'published', now() - interval '27 days'),

('b2b2b2b2-0004-4000-8000-000000000004', 'Oltu Taşı Kaplama Erkek Yüzüğü', 'Yüzük', 'Oltu Taşı',
 'Siyah oltu taşı, geniş yüzeyli erkek yüzüğü formunda gümüş çerçeveye oturtulmuştur. Mat dokusu ve hafifliği ile uzun süreli kullanımda rahatsızlık vermez. Sade ama karakterli bir görünüm arayanlar için tasarlanmıştır.',
 590.00, 6, '19-25 numara arası', 8.4, 'ucretsiz', 0,
 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0d/Whitby_Jet_%2841837232445%29.jpg/800px-Whitby_Jet_%2841837232445%29.jpg',
 ARRAY[
   'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0d/Whitby_Jet_%2841837232445%29.jpg/800px-Whitby_Jet_%2841837232445%29.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7b/Modern_jet_chain_link_%28section%29_%28FindID_289983%29.jpg/800px-Modern_jet_chain_link_%28section%29_%28FindID_289983%29.jpg'
 ], false, 'published', now() - interval '15 days'),

('b2b2b2b2-0004-4000-8000-000000000004', 'Kaplan Gözü Taşlı Gümüş Yüzük', 'Yüzük', 'Kaplan Gözü',
 'Kaplan gözü taşının karakteristik altın-kahve ışıltısı, sade bir gümüş çerçevede öne çıkarılmıştır. Taşın ışığa göre değişen görünümü sayesinde her ortamda farklı bir ton sergiler. Hem klasik hem modern kombinlere uyum sağlar.',
 610.00, 8, '17-23 numara arası', 6.2, 'ucretsiz', 0,
 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/be/Tiger%27s_eye.jpg/800px-Tiger%27s_eye.jpg',
 ARRAY[
   'https://upload.wikimedia.org/wikipedia/commons/thumb/b/be/Tiger%27s_eye.jpg/800px-Tiger%27s_eye.jpg'
 ], false, 'published', now() - interval '2 days'),

('b2b2b2b2-0004-4000-8000-000000000004', 'Firuze Taşlı Otantik Gümüş Yüzük', 'Yüzük', 'Firuze',
 'Doğu Anadolu motifleriyle işlenmiş gümüş çerçeve içine yuvalanmış firuze taşı. Firuzenin canlı mavi-yeşil tonu, taşın içerdiği bakır minerallerinden gelir ve zamanla cilt yağıyla temas ettikçe rengi derinleşebilir.',
 740.00, 7, '17-24 numara arası', 7.5, 'ucretsiz', 0,
 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a0/Silver_and_turquoise_rings.jpg/800px-Silver_and_turquoise_rings.jpg',
 ARRAY[
   'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a0/Silver_and_turquoise_rings.jpg/800px-Silver_and_turquoise_rings.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6d/Turquoise_and_silver_rings.jpg/800px-Turquoise_and_silver_rings.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Ring_with_turquoise_MET_sf74514259.jpg/800px-Ring_with_turquoise_MET_sf74514259.jpg'
 ], true, 'published', now() - interval '33 days'),

('b2b2b2b2-0004-4000-8000-000000000004', 'İkili Firuze Taşlı Yüzük', 'Yüzük', 'Firuze',
 'İki küçük firuze taşının yan yana yuvalandığı özgün tasarım bir yüzük. Gümüş işçiliği ince detaylarla süslenmiştir. Firuze, nazardan koruduğuna inanılan taşlar arasında sayılır ve hediye olarak da tercih edilir.',
 780.00, 5, '18-24 numara arası', 7.9, 'ucretsiz', 0,
 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6d/SILVER_AND_TURQUOISE_JEWELLERY_SET_%28Hunt_Museum%29.jpg/800px-SILVER_AND_TURQUOISE_JEWELLERY_SET_%28Hunt_Museum%29.jpg',
 ARRAY[
   'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6d/SILVER_AND_TURQUOISE_JEWELLERY_SET_%28Hunt_Museum%29.jpg/800px-SILVER_AND_TURQUOISE_JEWELLERY_SET_%28Hunt_Museum%29.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a0/Silver_and_turquoise_rings.jpg/800px-Silver_and_turquoise_rings.jpg'
 ], false, 'published', now() - interval '6 days'),

('b2b2b2b2-0004-4000-8000-000000000004', 'Yuvarlak Kesim Oniks Yüzük', 'Yüzük', 'Oniks',
 'Yuvarlak kesimli siyah oniks taşı sade bir gümüş yuvaya oturtulmuştur. Minimalist tasarımı sayesinde her yaş grubuna hitap eder. Oniksin derin siyahı, gümüşün parlaklığıyla kontrast oluşturur.',
 640.00, 8, '17-24 numara arası', 6.6, 'ucretsiz', 0,
 'https://upload.wikimedia.org/wikipedia/commons/1/1b/Onyx_Pearls_Necklace-1200.jpg',
 ARRAY[
   'https://upload.wikimedia.org/wikipedia/commons/1/1b/Onyx_Pearls_Necklace-1200.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/e/e7/Black_onyx_and_diamonds_ring.jpg'
 ], false, 'published', now() - interval '41 days'),

('b2b2b2b2-0004-4000-8000-000000000004', 'Akik Boncuklu Bileklik Tesbih (Cep Boy)', 'Tesbih', 'Akik',
 'Küçük boy akik boncuklardan hazırlanmış, cepte veya bilekte taşınabilen 33''lü mini tesbih. Seyahatte veya iş yerinde göz önünde tutmak isteyenler için pratik bir boyuttadır.',
 480.00, 12, '33''lü, Mini Boy', 14, 'ucretsiz', 0,
 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/26/Malawi_Agate_%28Malawi%2C_southeastern_Africa%29_%2832734668126%29.jpg/800px-Malawi_Agate_%28Malawi%2C_southeastern_Africa%29_%2832734668126%29.jpg',
 ARRAY[
   'https://upload.wikimedia.org/wikipedia/commons/thumb/2/26/Malawi_Agate_%28Malawi%2C_southeastern_Africa%29_%2832734668126%29.jpg/800px-Malawi_Agate_%28Malawi%2C_southeastern_Africa%29_%2832734668126%29.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d9/Modern_white_metal_and_layered_chalcedony_hinged_bracelet_%28FindID_1017837%29.jpg/800px-Modern_white_metal_and_layered_chalcedony_hinged_bracelet_%28FindID_1017837%29.jpg'
 ], false, 'published', now() - interval '1 days'),

-- ---- BURSA AHŞAP ATÖLYESİ: Sandal/Ceviz/Zeytin Ağacı + Pirinç ----
('b2b2b2b2-0005-4000-8000-000000000005', 'Hindistan Sandal Ağacı Tesbih', 'Tesbih', 'Sandal Ağacı',
 'Hindistan menşeli sandal ağacından 33''lü olarak tornalanmıştır. Sandal ağacının kendine özgü hafif ve tatlı kokusu, elde ısındıkça belirginleşir; bu koku yıllar içinde yavaşça azalır ama tamamen kaybolmaz. Doğal yağ cilası dışında kimyasal işlem uygulanmamıştır.',
 690.00, 9, '33''lü', 22, 'ucretsiz', 0,
 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cf/Tasbih_or_prayer_beads.jpg/800px-Tasbih_or_prayer_beads.jpg',
 ARRAY[
   'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cf/Tasbih_or_prayer_beads.jpg/800px-Tasbih_or_prayer_beads.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/Qur%27an_and_tespih.jpg/800px-Qur%27an_and_tespih.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/5/50/Muslim_Holding_a_Prayer_Counter_While_Performing_Tasbih.jpg/800px-Muslim_Holding_a_Prayer_Counter_While_Performing_Tasbih.jpg'
 ], false, 'published', now() - interval '52 days'),

('b2b2b2b2-0005-4000-8000-000000000005', 'Kokulu Sandal Ağacı Tesbih (99''lu)', 'Tesbih', 'Sandal Ağacı',
 'Büyük boy 99''lu sandal ağacı tesbih, geniş yüzeyli boncuklarıyla elde rahat kavranır. Sandal ağacının doğal aromatik yağları, boncukların gözeneklerinde uzun süre korunur. Cami hediyelik ürünleri arasında en çok tercih edilen ahşap tesbihlerden biridir.',
 990.00, 5, '99''lu', 45, 'ucretsiz', 0,
 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/Qur%27an_and_tespih.jpg/800px-Qur%27an_and_tespih.jpg',
 ARRAY[
   'https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/Qur%27an_and_tespih.jpg/800px-Qur%27an_and_tespih.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cf/Tasbih_or_prayer_beads.jpg/800px-Tasbih_or_prayer_beads.jpg'
 ], false, 'published', now() - interval '11 days'),

('b2b2b2b2-0005-4000-8000-000000000005', 'Ceviz Ağacı Damarlı Tesbih', 'Tesbih', 'Ceviz Ağacı',
 'Yerli ceviz ağacından, doğal damar desenleri korunarak tornalanmış 33''lü tesbih. Her boncuk aynı kütükten geldiği için desen akışı boncuklar arasında uyumludur. Ceviz ağacının koyu-açık ton geçişleri ışıkta belirginleşir.',
 640.00, 8, '33''lü', 25, 'ucretsiz', 0,
 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9c/Texture_de_noyer.jpg/800px-Texture_de_noyer.jpg',
 ARRAY[
   'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9c/Texture_de_noyer.jpg/800px-Texture_de_noyer.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7f/Muslim_in_White_Jallabiya_Reading_the_Qur%E2%80%99an_with_Tasbih_in_Hand.jpg/800px-Muslim_in_White_Jallabiya_Reading_the_Qur%E2%80%99an_with_Tasbih_in_Hand.jpg'
 ], false, 'published', now() - interval '19 days'),

('b2b2b2b2-0005-4000-8000-000000000005', 'Ceviz Ağacı Gümüş Detaylı Tesbih', 'Tesbih', 'Ceviz Ağacı',
 'Ceviz ağacı boncuklara, 925 ayar gümüş imame ve tepelik ile zarafet katılmıştır. Ahşabın sıcak tonu ile gümüşün soğuk parlaklığı arasındaki kontrast, tesbihi hem sade hem şık kılar.',
 850.00, 6, '33''lü', 28, 'ucretsiz', 0,
 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7f/Muslim_in_White_Jallabiya_Reading_the_Qur%E2%80%99an_with_Tasbih_in_Hand.jpg/800px-Muslim_in_White_Jallabiya_Reading_the_Qur%E2%80%99an_with_Tasbih_in_Hand.jpg',
 ARRAY[
   'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7f/Muslim_in_White_Jallabiya_Reading_the_Qur%E2%80%99an_with_Tasbih_in_Hand.jpg/800px-Muslim_in_White_Jallabiya_Reading_the_Qur%E2%80%99an_with_Tasbih_in_Hand.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9c/Texture_de_noyer.jpg/800px-Texture_de_noyer.jpg'
 ], false, 'published', now() - interval '4 days'),

('b2b2b2b2-0005-4000-8000-000000000005', 'Zeytin Ağacı Doğal Tesbih', 'Tesbih', 'Zeytin Ağacı',
 'Ege bölgesi zeytin ağacından, budak ve renk geçişleri korunarak işlenmiş 33''lü tesbih. Zeytin ağacının doğal yağı sayesinde ek cilaya ihtiyaç duymadan uzun yıllar parlaklığını korur. Her parça, ağacın kendine özgü desenini taşıdığı için tektir.',
 710.00, 7, '33''lü', 26, 'ucretsiz', 0,
 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/84/Olivesfromjordan.jpg/800px-Olivesfromjordan.jpg',
 ARRAY[
   'https://upload.wikimedia.org/wikipedia/commons/thumb/8/84/Olivesfromjordan.jpg/800px-Olivesfromjordan.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cf/Tasbih_or_prayer_beads.jpg/800px-Tasbih_or_prayer_beads.jpg'
 ], false, 'published', now() - interval '24 days'),

('b2b2b2b2-0005-4000-8000-000000000005', 'Budaklı Zeytin Ağacı Tesbih (99''lu)', 'Tesbih', 'Zeytin Ağacı',
 'Zeytin ağacının doğal budak izlerinin bilinçli olarak bırakıldığı, karakteristik bir 99''lu tesbih. Her boncuk farklı bir desen taşıdığından, bu tesbihin bir eşi daha yoktur. Zeytin ağacı ile özdeşleşen huzur ve sabır sembolizmini taşımasıyla bilinir.',
 1080.00, 4, '99''lu', 47, 'ucretsiz', 0,
 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cf/Tasbih_or_prayer_beads.jpg/800px-Tasbih_or_prayer_beads.jpg',
 ARRAY[
   'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cf/Tasbih_or_prayer_beads.jpg/800px-Tasbih_or_prayer_beads.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/8/84/Olivesfromjordan.jpg/800px-Olivesfromjordan.jpg'
 ], false, 'published', now() - interval '7 days'),

('b2b2b2b2-0005-4000-8000-000000000005', 'Pirinç İşlemeli Osmanlı Tesbih', 'Tesbih', 'Pirinç',
 'Pirinç tel işlemeli imame ve aralıklarla süslenmiş, Osmanlı motifli 33''lü tesbih. Pirincin altın rengi zamanla hafif matlaşarak antik bir görünüm kazanır; isteyen kullanıcılar özel pirinç parlatıcılarla eski parlaklığına döndürebilir.',
 560.00, 10, '33''lü', 31, 'ucretsiz', 0,
 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0e/Local_Brass_Bracelet.jpg/800px-Local_Brass_Bracelet.jpg',
 ARRAY[
   'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0e/Local_Brass_Bracelet.jpg/800px-Local_Brass_Bracelet.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/1/11/Local_Brass_Bracelet_II.jpg/800px-Local_Brass_Bracelet_II.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b1/WLA_brooklynmuseum_Ainu_Tamasay_Bead_Necklace.jpg/800px-WLA_brooklynmuseum_Ainu_Tamasay_Bead_Necklace.jpg'
 ], false, 'published', now() - interval '37 days'),

('b2b2b2b2-0005-4000-8000-000000000005', 'Pirinç Boncuklu Zikirlik', 'Tesbih', 'Pirinç',
 'Tamamı pirinç boncuklardan oluşan, ağırlığı elde belirgin hissedilen sağlam bir zikirlik. Metal boncukların birbirine çarpma sesi, zikir sırasında ritmik bir geri bildirim sağladığı için bazı kullanıcılar tarafından özellikle tercih edilir.',
 610.00, 6, '33''lü', 52, 'ucretsiz', 0,
 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/11/Local_Brass_Bracelet_II.jpg/800px-Local_Brass_Bracelet_II.jpg',
 ARRAY[
   'https://upload.wikimedia.org/wikipedia/commons/thumb/1/11/Local_Brass_Bracelet_II.jpg/800px-Local_Brass_Bracelet_II.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0e/Local_Brass_Bracelet.jpg/800px-Local_Brass_Bracelet.jpg'
 ], false, 'published', now() - interval '13 days'),

-- ---- KAPADOKYA MÜCEVHER: Zümrüt, Yakut, Altın, Sade ----
('b2b2b2b2-0006-4000-8000-000000000006', 'Zümrüt Kesim Yeşil Taşlı Yüzük', 'Yüzük', 'Zümrüt Kesim',
 'Klasik zümrüt kesim (basamaklı dikdörtgen) ile kesilmiş yeşil taş, 14 ayar altın kaplama çerçeveye yuvalanmıştır. Zümrüt kesimi, taşın derinliğini ve netliğini ön plana çıkarır; bu yüzden özellikle net renkli taşlarda tercih edilir.',
 1250.00, 5, '17-23 numara arası', 5.4, 'ucretsiz', 0,
 'https://upload.wikimedia.org/wikipedia/commons/0/05/Emerald_ring_1.jpg',
 ARRAY[
   'https://upload.wikimedia.org/wikipedia/commons/0/05/Emerald_ring_1.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/f/f5/Emerald_ring_2.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/2/2f/Emerald_Ring.jpg'
 ], true, 'published', now() - interval '44 days'),

('b2b2b2b2-0006-4000-8000-000000000006', 'Zümrüt Taşlı Vintage Yüzük', 'Yüzük', 'Zümrüt Kesim',
 'Eski dönem yüzük tasarımlarından ilham alınarak hazırlanmış, zümrüt kesim taşlı vintage bir model. Çerçeve detaylarında el oyması motifler bulunur. Koleksiyoncu ruhuna hitap eden, iddialı bir parçadır.',
 1390.00, 3, '18-24 numara arası', 6.1, 'ucretsiz', 0,
 'https://upload.wikimedia.org/wikipedia/commons/1/1e/Medieval_emerald_ring.jpg',
 ARRAY[
   'https://upload.wikimedia.org/wikipedia/commons/1/1e/Medieval_emerald_ring.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/5/54/Emerald_and_diamond_ring.jpg/800px-Emerald_and_diamond_ring.jpg'
 ], false, 'published', now() - interval '16 days'),

('b2b2b2b2-0006-4000-8000-000000000006', 'Zümrüt Yeşili Taşlı İnce Yüzük', 'Yüzük', 'Zümrüt Kesim',
 'İnce gövdeli, tek taş zümrüt kesim yeşil taşlı bir tasarım. Diğer yüzüklerle kombinlenmeye uygun zarif bir profildedir. Günlük kullanım için hafif ve rahat bir alyans genişliğine sahiptir.',
 1180.00, 6, '17-22 numara arası', 4.9, 'ucretsiz', 0,
 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ad/Emerald_ring_photo_by_Somma.jpg/800px-Emerald_ring_photo_by_Somma.jpg',
 ARRAY[
   'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ad/Emerald_ring_photo_by_Somma.jpg/800px-Emerald_ring_photo_by_Somma.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/0/05/Emerald_ring_1.jpg'
 ], false, 'published', now() - interval '0 days'),

('b2b2b2b2-0006-4000-8000-000000000006', 'Kırmızı Yakut Taşlı Altın Kaplama Yüzük', 'Yüzük', 'Yakut',
 'Derin kırmızı tonlu yakut taşı, 14 ayar altın kaplama üzerine tek taş olarak işlenmiştir. Yakut, sertlik bakımından elmastan sonra gelen taşlardan biridir; bu sayede günlük kullanımda çizilme riski düşüktür.',
 1420.00, 4, '17-24 numara arası', 5.8, 'ucretsiz', 0,
 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/28/Poetry_-_gold_ring_with_large_ruby_-_cropped.jpg/800px-Poetry_-_gold_ring_with_large_ruby_-_cropped.jpg',
 ARRAY[
   'https://upload.wikimedia.org/wikipedia/commons/thumb/2/28/Poetry_-_gold_ring_with_large_ruby_-_cropped.jpg/800px-Poetry_-_gold_ring_with_large_ruby_-_cropped.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/8/81/Poetry_-_gold_ring_with_large_ruby.jpg/800px-Poetry_-_gold_ring_with_large_ruby.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b6/Gold_ring_with_a_ruby.jpg/800px-Gold_ring_with_a_ruby.jpg'
 ], true, 'published', now() - interval '58 days'),

('b2b2b2b2-0006-4000-8000-000000000006', 'Yuvarlak Kesim Yakut Taşlı Yüzük', 'Yüzük', 'Yakut',
 'Yuvarlak kesimli yakut taşının sadeliği, ince altın kaplama çerçeveyle dengelenmiştir. Klasik ve zamansız bir tasarım arayanlar için uygundur. Hediyelik kutusu ile birlikte gönderilir.',
 1340.00, 5, '17-23 numara arası', 5.2, 'ucretsiz', 0,
 'https://upload.wikimedia.org/wikipedia/commons/1/1a/Ruby_ring_photo_by_stevendepolo.jpg',
 ARRAY[
   'https://upload.wikimedia.org/wikipedia/commons/1/1a/Ruby_ring_photo_by_stevendepolo.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/6/66/Ruby_ring_photo_by_bfishadow.jpg/800px-Ruby_ring_photo_by_bfishadow.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b4/Ruby_ring_photo_by_by_bfishadow.jpg/800px-Ruby_ring_photo_by_by_bfishadow.jpg'
 ], false, 'published', now() - interval '21 days'),

('b2b2b2b2-0006-4000-8000-000000000006', 'Tek Taş Yakut Nişan Yüzüğü', 'Yüzük', 'Yakut',
 'Nişan ve söz törenleri için özel olarak tasarlanmış, tek taş yakut işlemeli bir yüzük. Zarif çerçeve detayları taşın parlaklığını ön planda tutacak şekilde minimalist bırakılmıştır.',
 1510.00, 3, '16-22 numara arası', 5.0, 'ucretsiz', 0,
 'https://upload.wikimedia.org/wikipedia/commons/d/d3/Ruby_Ring.png',
 ARRAY[
   'https://upload.wikimedia.org/wikipedia/commons/d/d3/Ruby_Ring.png',
   'https://upload.wikimedia.org/wikipedia/commons/1/1a/Ruby_ring_photo_by_stevendepolo.jpg'
 ], false, 'published', now() - interval '3 days'),

('b2b2b2b2-0006-4000-8000-000000000006', 'Sade Altın Kaplama Alyans', 'Yüzük', 'Altın',
 'Düz yüzeyli, taşsız 14 ayar altın kaplama alyans modeli. Nikaha veya günlük kullanıma uygun sade bir tasarımdır. İç yüzeyi konfor bantlı olduğundan uzun süreli takıda rahatsızlık vermez.',
 780.00, 12, '16-23 numara arası', 4.5, 'ucretsiz', 0,
 'https://upload.wikimedia.org/wikipedia/commons/1/1a/Undated_plain_gold_band_or_finger_ring_%28FindID_176128%29.jpg',
 ARRAY[
   'https://upload.wikimedia.org/wikipedia/commons/1/1a/Undated_plain_gold_band_or_finger_ring_%28FindID_176128%29.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/d/df/Gold_wedding_ring.jpg/800px-Gold_wedding_ring.jpg'
 ], false, 'published', now() - interval '29 days'),

('b2b2b2b2-0006-4000-8000-000000000006', 'İkiz Bantlı Sade Yüzük', 'Yüzük', 'Sade',
 'İki ince bandın yan yana durduğu, taşsız ve modern bir sade yüzük tasarımı. Tek başına şık, başka yüzüklerle birlikte katmanlı kullanıma da uygun. Hem kadın hem erkek ölçülerinde üretilebilir.',
 540.00, 14, '16-24 numara arası', 4.0, 'ucretsiz', 0,
 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6a/2012_T456_A_Post_Medieval_gold_finger_ring_%28FindID_568813%29.jpg/800px-2012_T456_A_Post_Medieval_gold_finger_ring_%28FindID_568813%29.jpg',
 ARRAY[
   'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6a/2012_T456_A_Post_Medieval_gold_finger_ring_%28FindID_568813%29.jpg/800px-2012_T456_A_Post_Medieval_gold_finger_ring_%28FindID_568813%29.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/1/1a/Undated_plain_gold_band_or_finger_ring_%28FindID_176128%29.jpg'
 ], false, 'published', now() - interval '10 days'),

('b2b2b2b2-0006-4000-8000-000000000006', 'Lületaşı Detaylı Sultani Tesbih', 'Tesbih', 'Lületaşı',
 'Eskişehir lületaşından işlenmiş imame ve tepelik parçalarıyla tamamlanan sultani boy bir tesbihtir. Lületaşı, hafifliği ve mat beyaz tonuyla dikkat çeker; zamanla elde tutuldukça hafif sararma yaparak "işlenmiş" bir görünüm kazanır — bu, koleksiyoncular arasında değerli sayılan bir özelliktir.',
 1780.00, 3, 'Sultani Boy, 33''lü', 35, 'ucretsiz', 0,
 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/40/Mineraly.sk_-_sepiolit.jpg/800px-Mineraly.sk_-_sepiolit.jpg',
 ARRAY[
   'https://upload.wikimedia.org/wikipedia/commons/thumb/4/40/Mineraly.sk_-_sepiolit.jpg/800px-Mineraly.sk_-_sepiolit.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cf/Tasbih_or_prayer_beads.jpg/800px-Tasbih_or_prayer_beads.jpg'
 ], false, 'published', now() - interval '38 days'),

('b2b2b2b2-0006-4000-8000-000000000006', 'Doğal Lületaşı Zikirlik', 'Tesbih', 'Lületaşı',
 'Küçük boy, günlük kullanıma uygun lületaşı zikirlik. Hafifliği sayesinde cepte taşınması pratiktir. Doğal gözenekli yapısı, elin doğal yağlarıyla temas ettikçe rengini yavaşça değiştirir.',
 1320.00, 4, '33''lü, Mini Boy', 20, 'ucretsiz', 0,
 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/Qur%27an_and_tespih.jpg/800px-Qur%27an_and_tespih.jpg',
 ARRAY[
   'https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/Qur%27an_and_tespih.jpg/800px-Qur%27an_and_tespih.jpg',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/4/40/Mineraly.sk_-_sepiolit.jpg/800px-Mineraly.sk_-_sepiolit.jpg'
 ], false, 'published', now() - interval '14 days')

on conflict do nothing;
