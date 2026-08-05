# Project Journal

## Roadmap
Nova7, Brezilya pazarında faaliyet gösteren, birden fazla satıcıyı bir araya getiren bir e-ticaret pazar yeri (marketplace). Şirket son dönemde pazarlama harcamalarını artırdı ve farklı kanallardan (organik arama, sosyal medya, referans, ücretli reklam vs.) lead topluyor. Ancak yönetim ekibi şu soruyu soruyor: "Pazarlamaya harcadığımız paranın karşılığını alıyor muyuz, ve kazandığımız müşteriler gerçekten değerli mi?"

Sana (veri analisti olarak) şu görev veriliyor: lead'den satışa dönüşüm sürecini analiz et, hangi kanalların gerçekten değerli (tekrar alışveriş yapan, yüksek harcamalı) müşteri getirdiğini bul, ve yönetime "nereye daha çok yatırım yapmalıyız" konusunda veriye dayalı bir öneri sun

Taşıyıcı doğrulaması, az sayıda olağandışı zaman damgası anormalliği (özellikle ~10 günlük ve ~172 günlük negatif gecikmeler) tespit etti. Bu kayıtlar, iş metriklerini etkileyip etkilemediklerini veya izole veri kalitesi sorunlarını temsil edip etmediklerini belirlemek için Keşifsel Veri Analizi aşamasında yeniden incelenecektir.

### Goal

Hangi pazarlama kanalları (lead kaynakları) en çok gerçek satışa dönüşen müşteriyi getiriyor?
Dönüşen müşteriler arasında kimler tekrar alışveriş yapıyor, kimler tek seferlik kalıyor — bu ikisi arasındaki fark ne (bölge, harcama tutarı, kategori tercihi vs.)?
En değerli müşteri segmentleri hangi özelliklere sahip (RFM tarzı bir segmentasyon: Recency-Frequency-Monetary)?
(Opsiyonel yan bulgu) Teslimat deneyimi (gecikme, review skoru) müşterinin tekrar alışveriş yapma olasılığını etkiliyor mu?

Örneğin veri temizleme fonksiyonlarını python/cleaning.py gibi bir dosyada tut, notebook'ta sadece from cleaning import clean_orders diye çağır. Bu hem notebook'u temiz tutar hem de "bu kişi sadece notebook'ta kod yazmıyor, modüler düşünüyor" mesajı verir — junior/orta seviye adaylarda nadir görülen bir olgunluk işareti.

En son bir "hikaye anlatan" özet doküman:
Notebook'lar senin çalışma alanın; ama bir işe alım uzmanı bunların hepsini okumayacak. README.md'de (veya 05_final_summary.ipynb'de) 5-6 paragraflık, teknik detaya boğulmadan "problem neydi, ne yaptım, ne buldum, ne önerdim" akışında bir özet olmalı, dashboard ekran görüntüleriyle desteklenmiş.


### Decisions

Notebook klasöründe keşif, denemeler, EDA, hipotez testleri.
Python klasöründe temizlenmiş, tekrar kullanılabilir kodlar.
SQL'de sql scriptleri.
PowerBI'da dashboard'lar.

1. Data Discovery
        ↓
2. Data Validation
        ↓
3. Data Cleaning
        ↓
4. Feature Engineering
        ↓
5. EDA
        ↓
6. Statistical Analysis
        ↓
7. Business Insights
        ↓
8. Dashboard
        ↓
9. GitHub & Documentation

### What I Learned

Customers veritabanında customer_id ve customer_unique_id olmasının sebebi örneğin ben bir e-ticaret sitesiyim. Sen benden bugün alışveriş yaptın. Sana bir customer_id verdim. Sonra hesabını sildin. 3 ay sonra tekrar üye oldun. Sence ben sana aynı customer_id'yi mi veririm? Muhtemelen hayır. Ama gerçekte aynı kişi sensin. İşte burada ikinci bir kimlik gerekebilir.
Describe() ile oluşan top, en sık görülen değer; freq ise o değerin kaç kez görüldüğüdür.
sort_values(ascending=false) ifadesi büyükten küçüğe sıralamayı sağladı, true olsaydı küçükten büyüğe sıralardı.
Bu bir düşünme modeli: Hypothesis → Evidence → Conclusion
Hipotez: Aynı gerçek müşteri zaman içinde birden fazla müşteri kaydı oluşturmuş olabilir.
Kanıt: Aynı customer_unique_id birden fazla customer_id ile eşleşiyor. Bazı kayıtların şehir, eyalet ve ZIP prefix bilgileri aynı.
Sonuç: Mevcut veriler hipotezi desteklemektedir; ancak bunun kesin nedeni mevcut veriyle doğrulanamaz.

order_item_id tek başına primary key değildir. Olist veri setinde order_item_id, her sipariş içinde satır numarası gibi çalışır. Asıl benzersiz anahtar (order_id, order_item_id) ikilisidir. Buna composite (bileşik) primary key denir. Gördüğün her id primary key olmak zorunda değildir.
product_name_length sütunu, çok uzun başlıkların SEO veya satış performansı açıdan nasıl bir etki yarattığını anlamak için önemlidir.
İlk bakışta order_reviews tablosundaki "review_answer_timestamp" sütunu yapılan yoruma ne zaman cevap verildiği gibi düşünülebilir. Ancak bundan hemen emin olamayız. Sistem ne zaman yorumu işledi, şirket ne zaman yanıt verdi, müşteri anketi ne zaman tamamladı gibi durumları da temsil ediyor olabilir.

veri temizlemede ilk 10-20 arasındaki kısımda tarih dönüşümleri kiminde astype kiminde pd.to_datetime ile olmuş. bunun sebebi örneğin str to datetime gibi dönüşümlerde her zaman pdf.to_datetime kullan çünkü pandas string'i ayrıştırıp anlamlandırıyor falan. astype ise bu ayrıştırma mantığını içermiyor, genelde basit tip dönüşümleri için kullanıyor int to float, int to str gibi

~ (tilde) — mantıksal DEĞİL (NOT) operatörü.
İçerideki (orders['order_status'] == 'delivered') & (orders['order_delivered_customer_date'].isnull()) ifadesi, her satır için True/False üreten bir "maske" oluşturuyor — yani "bu satır hem delivered hem de teslimat tarihi boş mu?" sorusuna cevap veriyor.
Ama bizim istediğimiz bu satırları çıkarmak, yani tersini almak — "bu koşulu SAĞLAMAYAN satırları tut." İşte ~ tam burada devreye giriyor: True olanları False'a, False olanları True'ya çeviriyor. Yani ~(...) demek "bu koşula uymayan her şey" demek.
Somut örnekle: eğer koşul [True, False, True] üretiyorsa, ~koşul bunu [False, True, False]'a çevirir. orders[~koşul] yazınca, sadece True olan (yani koşula uymayan, bizim tutmak istediğimiz) satırları alırsın.

.copy() — pandas'ın "SettingWithCopyWarning" tuzağından kaçınmak için.
orders[...] gibi bir filtreleme yaptığında, pandas bazen bunun orijinal DataFrame'in bir "görünümü" (view) mü yoksa tamamen yeni, bağımsız bir kopya mı olduğuna kendi de tam karar veremiyor. Eğer sen orders_clean üzerinde ileride değişiklik yaparsan (örneğin yeni bir sütun eklersen), pandas bazen "bu değişikliği orijinal orders'a mı yapıyorsun, yeni DataFrame'e mi yapıyorsun, emin değilim" diye bir uyarı fırlatabilir, hatta bazı durumlarda beklenmedik davranışlara yol açabilir.
.copy() eklemek, pandas'a açıkça "bu artık tamamen bağımsız, yeni bir DataFrame, orijinaliyle hiçbir bağı yok" demek. Bu, ileride orders_clean üzerinde güvenle değişiklik yapabilmen için bir güvenlik önlemi — profesyonel kodda neredeyse her filtreleme sonrası bu alışkanlık görülür.

Bizim weight kararımızın gerekçesi netleşti mi: Std'nin mean'den büyük olduğunu zaten görmüştük (çarpık dağılım) → bu yüzden mean değil medyan seçtik → ve bunu genel medyan yerine kategori bazında (cama_mesa_banho'nun kendi medyanı) yaptık çünkü farklı kategoriler (örn. bir elektronik ürün vs bir çarşaf) çok farklı tipik ağırlıklara sahip olabilir, genel medyan yanıltıcı olurdu. Yani bu "ben öyle dedim" değil, verinin kendi özelliklerinden (çarpıklık + kategori farklılığı) çıkan bir karar — bunu markdown'a da bu gerekçeyle yaz.

.loc[] içine iki şey veriyorsun, virgülle ayırarak: .loc[satır_seçimi, sütun_seçimi]
Virgülden önceki kısım (satır seçimi):
order_payments_clean['payment_type'] == 'not_defined'
Bu, "hangi satırları hedefliyorum" sorusuna cevap veren bir True/False maskesi üretiyor — payment_type'ı 'not_defined' olan satırlarda True, diğerlerinde False.
Virgülden sonraki kısım (sütun seçimi):
'payment_type'
Bu, "hangi sütunu değiştirmek istiyorum" sorusuna cevap veriyor. Yani "seçtiğim satırlarda, payment_type sütununu değiştir" diyorsun.
Sağındaki = 'unknown': Seçtiğin (satır, sütun) kesişimindeki tüm hücrelere 'unknown' değerini ata.
Neden payment_type'ı iki kere yazdık, biraz garip görünüyor haklısın — açıklayayım:
İlk kullanım (== ile), "hangi satırları filtreleyeceğim" için bir koşul kuruyor — burada payment_type sütununa bakıp "not_defined mı?" diye soruyoruz.
İkinci kullanım (virgülden sonraki), "seçtiğim bu satırların hangi sütununu değiştireceğim" diye belirtiyor — burada da yine payment_type sütununu hedefliyoruz çünkü değiştirmek istediğimiz alan yine o.
Neden direkt böyle yazmadık peki (.loc kullanmadan):
order_payments_clean[order_payments_clean['payment_type'] == 'not_defined']['payment_type'] = 'unknown'
Bu, tam olarak biraz önce bahsettiğim SettingWithCopyWarning tuzağına düşer — pandas bu şekilde zincirleme (chained) bir atama yapıldığında değişikliğin gerçek DataFrame'e mi yoksa geçici bir kopyaya mı uygulandığından emin olamaz, bazen sessizce işe yaramaz. .loc[] kullanmak, bu belirsizliği ortadan kaldırıp "ben tam olarak bu satır-sütun kesişimini değiştiriyorum" diye pandas'a net bir talimat verir. Bu yüzden pandas'ta değer atarken her zaman .loc[] kullan alışkanlığını edinmen iyi olur.

Kod satır satır açıklaması
python
dup_order_ids = order_reviews_clean['order_id'].value_counts()
order_id sütunundaki her bir değerin kaç kere tekrar ettiğini sayar. Sonuç, order_id'lerin index, tekrar sayılarının değer olduğu bir Seri (Series) olur. Örneğin order_id_X: 2 demek, o sipariş için 2 review var demek.
dup_order_ids = dup_order_ids[dup_order_ids > 1].index
Burada iki şey oluyor sırayla:
dup_order_ids[dup_order_ids > 1] → az önce oluşturduğumuz sayım listesini filtreliyor, sadece 1'den fazla tekrar edenleri tutuyor (yani gerçekten duplicate olan siparişleri)
.index → filtrelenmiş bu Seri'nin index kısmını (yani order_id'lerin kendisini, sayıları değil) alıyoruz. Çünkü bir sonraki adımda bize sayı değil, hangi order_id'lerin duplicate olduğu lazım.
python
order_reviews_clean[order_reviews_clean['order_id'].isin(dup_order_ids)].sort_values(['order_id', 'review_creation_date'])
order_reviews_clean['order_id'].isin(dup_order_ids) → her satır için "bu satırın order_id'si, duplicate olan listede var mı?" diye True/False üretir
order_reviews_clean[...] → bu True/False maskesini kullanarak, sadece duplicate olan siparişlere ait tüm satırları filtreler
.sort_values(['order_id', 'review_creation_date']) → sonucu önce order_id'ye göre, sonra (aynı order_id içinde) review_creation_date'e göre sıralar — bu, aynı siparişin review'larının yan yana ve tarih sırasına göre görünmesini sağlar, karşılaştırma yapman kolaylaşır
.head(20) → ilk 20 satırı göster (hepsini değil, göz atmak için yeterli bir örnek)

| işareti OR VEYA, &  işareti VE AND, ~ DEĞİL NOT anlamına geliyor.

Hayır. "Herhangi biri aynıysa" demiyor.
Aslında şunu diyor: "Bu sütunların HEPSİ birlikte aynıysa duplicate kabul et."
Bu kod:
products.duplicated(
    subset=[
        "product_category_name",
        "product_name_lenght",
        "product_description_lenght",
        "product_photos_qty",
        "product_weight_g",
        "product_length_cm",
        "product_height_cm",
        "product_width_cm"
    ]
)

Understanding kısmındaki tekrar eden ürünler, keep'li kod için: 
keep=False
Normalde duplicated() sadece ikinci, üçüncü... tekrarları True yapar.
keep=False dediğimizde ise duplicate grubundaki tüm satırları gösterir.
keep aslında ne yapıyor?
product
A
A
A
B
C
C
Normal hali duplicated():
product	duplicate
A	False
A	True
A	True
B	False
C	False
C	True
İlkini bırakıyor.

Çünkü default: keep="first"
Eğer keep=False:
product	duplicate
A	True
A	True
A	True
B	False
C	True
C	True
Artık duplicate grubunun tamamını işaretliyor.

products_clean.loc[
    products_clean["product_weight_g"] == 0,
    "product_weight_g"
] = pd.NA

loc'un mantığı: [satırlar, sütunlar]
Yani bu kodda satırlarda ağırlığı 0 olanlar olacak, sütunlarda ise yalnızca ağırlık sütunu gösterilecek
pd.NA kısmı ise seçtiğin bu "hücreleri" NaN yap anlamında
SQL'de UPDATE products SET product_weight_g = NULL WHERE product_weight_g = 0; karşılığı.

order_payments_clean["payment_installments"].eq(0).sum() anlamı taksit sayısı 0 olan kayıtların toplamı. ==0 ın fonksiyon halidir.

Birden fazla dataframe üzerinde aynı işlemi uygulamak gerektiğinde, her dataframe için ayrı kod yazmak yerine for döngüsü ve dictionary kullanılarak işlem otomatikleştirilebilir.

.value_counts(dropna=False) kodunda dropna=False, "NaN ları da say ihmal etme" anlamına gelir

assign(), birden fazla sütunu tek seferde oluşturur. Tek tek yapmak yerine bu metot, kodu daha okunabilir hale getirir.

value_counts içinde kullanılan "normalize=True" fonksiyonu, oran verir.



### Problems

Claude "xtamam anladım kodu süpersin." kısmında kaldı data cleaning.


### Ideas