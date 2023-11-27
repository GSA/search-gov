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

export const truncateUrl = (text: string | undefined, length: number): string => {
  if (text === undefined) {
    return '';
  }

  const result = stripProtocols(text);
  if (result.length <= length) {
    return result;
  }

  return `${result.substring(0, length)}...`;
};

const stripProtocols = (url: string): string => {
  return url.replace(/(^\w+:|^)\/\//, '');
};

export const getTextWidth = (text: string): number => {
  const canvas = document.createElement('canvas');
  const context = canvas.getContext('2d');

  if (context) {
    const { fontFamily } = getComputedStyle(document.body);

    context.font = `bold 0.93rem ${fontFamily}`;

    return context.measureText(text).width;
  }

  return 0;
};

export const move = <T>(input: T[], from: number, to: number): T[] => {
  let numberOfDeletedElm = 1;

  const [elm] = input.splice(from, numberOfDeletedElm);

  numberOfDeletedElm = 0;

  return input.splice(to, numberOfDeletedElm, elm);
};
