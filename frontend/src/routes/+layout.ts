export const prerender = true;
export const ssr = false;

export function load({ url }) {
    const start_text = url.searchParams.get('start_text');
    console.log('start_text', start_text);
  return { start_text };
}
