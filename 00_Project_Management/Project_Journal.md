# Project Journal

## Roadmap
Nova7, Brezilya pazarında faaliyet gösteren, birden fazla satıcıyı bir araya getiren bir e-ticaret pazar yeri (marketplace). Şirket son dönemde pazarlama harcamalarını artırdı ve farklı kanallardan (organik arama, sosyal medya, referans, ücretli reklam vs.) lead topluyor. Ancak yönetim ekibi şu soruyu soruyor: "Pazarlamaya harcadığımız paranın karşılığını alıyor muyuz, ve kazandığımız müşteriler gerçekten değerli mi?"

Sana (veri analisti olarak) şu görev veriliyor: lead'den satışa dönüşüm sürecini analiz et, hangi kanalların gerçekten değerli (tekrar alışveriş yapan, yüksek harcamalı) müşteri getirdiğini bul, ve yönetime "nereye daha çok yatırım yapmalıyız" konusunda veriye dayalı bir öneri sun

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


### Problems


### Ideas