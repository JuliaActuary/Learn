
#![feature(test)]
extern crate test;
use test::Bencher;

// Via Paddy Horan
pub fn npv(mortality_rates: &Vec<f64>, lapse_rates: &Vec<f64>, interest_rate: f64, sum_assured: f64, premium: f64, init_pols: f64, term: Option<usize>) -> f64 {

    let term = term.unwrap_or_else(|| mortality_rates.len());
    let mut result = 0.0;
    let mut inforce = init_pols;
    let v: f64 = 1.0 / (1.0 + interest_rate);
    let mut discount_factor: f64 = 1.0;

    for (t, (q, w)) in mortality_rates.iter().zip(lapse_rates).enumerate() {
        let no_deaths = if t < term {inforce * q} else {0.0};
        let no_lapses = if t < term {inforce * w} else {0.0};
        let premiums = inforce * premium;
        let claims = no_deaths * sum_assured;
        let net_cashflow = premiums - claims;
        result += net_cashflow * discount_factor;
		discount_factor *= v;
        inforce = inforce - no_deaths - no_lapses;
    }

    result
}



// fn main() {

// print!("{}",npv(&q,&w,r,s,p,1.0,Some(10)));
#[bench]
fn bench_xor_1000_ints(b: &mut Bencher) {

let q: Vec<f64> = vec![0.001,0.002,0.003,0.003,0.004,0.004,0.005,0.007,0.009,0.011];
let w: Vec<f64> = vec![0.05,0.07,0.08,0.10,0.14,0.20,0.20,0.20,0.10,0.04];
let p: f64 = 100.0;
let s: f64 = 25000.0;
let r: f64 = 0.02;
    b.iter(|| {
        // use `test::black_box` to prevent compiler optimizations from disregarding
        // unused values
        test::black_box(npv(&q,&w,r,s,p,1.0,Some(10)));
    });
}
// }
