export const getUriWithParam = (baseUrl: string, urlParam: string, urlParamQuery: string): string => {
  const Url = new URL(baseUrl);
  const urlParams: URLSearchParams = new URLSearchParams(Url.search);
  if (urlParam === 'query' && urlParams.has('page')) {
    urlParams.delete('page');
  }
  urlParams.set(urlParam, urlParamQuery);
  Url.search = urlParams.toString();
  return Url.toString();
};

export const getCurrentPage = (): number => {
  const queryString = window.location.search;
  const urlParams = new URLSearchParams(queryString);
  return Number(urlParams.get('page')) ? Number(urlParams.get('page')) : 1;
};
