export class JsScalarEngine {
  constructor(){this.previous=null;this.gray=null;this.temp=null;this.blur=null;this.output=null;}
  reset(){this.previous=null;}
  process(image,w,h,threshold=30){const n=w*h,d=image.data;if(!this.gray||this.gray.length!==n){this.gray=new Uint8Array(n);this.temp=new Uint16Array(n);this.blur=new Uint8Array(n);this.output=new Uint8ClampedArray(n*4);}for(let i=0;i<n;i++){const p=i*4;this.gray[i]=(77*d[p]+150*d[p+1]+29*d[p+2])>>8;}
    const r=3,s=7;for(let y=0;y<h;y++){let sum=0;for(let k=0;k<s&&k<w;k++)sum+=this.gray[y*w+k];if(w>2*r){this.temp[y*w+r]=sum;for(let x=r+1;x<w-r;x++){sum+=this.gray[y*w+x+r]-this.gray[y*w+x-r-1];this.temp[y*w+x]=sum;}}}
    const area=49;for(let x=0;x<w;x++){let sum=0;for(let k=0;k<s&&k<h;k++)sum+=this.temp[k*w+x];if(h>2*r){this.blur[r*w+x]=sum/area;for(let y=r+1;y<h-r;y++){sum+=this.temp[(y+r)*w+x]-this.temp[(y-r-1)*w+x];this.blur[y*w+x]=sum/area;}}}
    let changed=0;for(let i=0;i<n;i++){let v=0;if(this.previous){const d0=this.blur[i]-this.previous[i];v=(d0>threshold||d0<-threshold)?255:0;changed+=v!==0;}const p=i*4;this.output[p]=this.output[p+1]=this.output[p+2]=v;this.output[p+3]=255;}this.previous=this.blur.slice();return {changed,output:this.output};}
}
