const { initializeTestEnvironment, assertSucceeds, assertFails } = require('@firebase/rules-unit-testing');
const { doc, setDoc, getDoc, serverTimestamp, Bytes, updateDoc } = require('firebase/firestore');
const fs = require('fs');
(async () => {
 const env = await initializeTestEnvironment({projectId: 'demo-real-estate', firestore: {host:'127.0.0.1', port:8787, rules:fs.readFileSync(require('path').join(__dirname,'../../firestore.rules'),'utf8')}});
 const owner = env.authenticatedContext('owner').firestore();
 const other = env.authenticatedContext('other').firestore();
 const guest = env.unauthenticatedContext().firestore();
 const photo = n => Bytes.fromUint8Array(new Uint8Array(n));
 const listing = photos => ({title:'Test',type:'Apartment',governorate:'Luxor',location:'Luxor',mode:'rent',price:100,bedrooms:2,bathrooms:1,area:90,description:'',photoBytes:photos,ownerId:'owner',status:'available',createdAt:serverTimestamp(),lastConfirmedAt:serverTimestamp()});
 try {
  await assertSucceeds(setDoc(doc(owner,'properties/valid'),listing([photo(122880),photo(122880),photo(122880),photo(122880)])));
  await assertFails(setDoc(doc(owner,'properties/too-big'),listing([photo(122881)])));
  await assertFails(setDoc(doc(owner,'properties/too-many'),listing(Array(5).fill(photo(1)))));
  await assertFails(setDoc(doc(owner,'properties/empty'),listing([])));
  await assertFails(setDoc(doc(owner,'properties/empty-photo'),listing([photo(0)])));
  await assertFails(setDoc(doc(owner,'properties/string'),listing(['not bytes'])));
  await assertFails(setDoc(doc(other,'properties/wrong-owner'),listing([photo(1)])));
  await assertFails(setDoc(doc(guest,'properties/guest'),listing([photo(1)])));
  await assertSucceeds(getDoc(doc(guest,'properties/valid')));
  await assertSucceeds(updateDoc(doc(owner,'properties/valid'),{lastConfirmedAt:serverTimestamp()}));
  await assertFails(updateDoc(doc(other,'properties/valid'),{lastConfirmedAt:serverTimestamp()}));
  await assertFails(updateDoc(doc(owner,'properties/valid'),{photoBytes:[photo(2)]}));
  console.log('12 Firestore rules assertions passed');
 } finally { await env.cleanup(); }
})().catch(e => {console.error(e);process.exit(1)});
