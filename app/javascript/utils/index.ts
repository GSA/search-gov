/* eslint-disable camelcase */
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

export const clickTracking = (affiliate: string, module: string, query: string, position: number, url: string, vertical: string) => {
  fetch('/clicked', {
    method: 'POST',
    headers: {
      Accept: 'application/json',
      'Content-Type': 'application/json'
    },
    mode: 'cors',
    body: JSON.stringify({
      affiliate,
      url,
      module_code: module,
      position,
      query,
      vertical
    })
  });
};

// Below calculation is as per https://www.w3.org/WAI/GL/wiki/Relative_luminance
const getLuminance = (red: number, green: number, blue: number) => {
  const rgb = [red, green, blue].map((index) => {
    const value = index / 255;
    return value <= 0.03928
      ? value / 12.92
      : Math.pow((value + 0.055) / 1.055, 2.4);
  });
  return rgb[0] * 0.2126 + rgb[1] * 0.7152 + rgb[2] * 0.0722;
};

const getRgbColorObject = (color: string) => {
  const rgbStrLen = 4;
  // extracting red, green and blue from rgb(red, green, blue)
  const colorArr = color.substring(rgbStrLen, color.lastIndexOf(')')).split(', ');
  return {
    red: parseInt(colorArr[0], 10),
    green: parseInt(colorArr[1], 10),
    blue: parseInt(colorArr[2], 10)
  };
};

/*
  AA-level small text: ${contrastRatio < 1/4.5 ? 'PASS' : 'FAIL' }
  AAA-level small text: ${contrastRatio < 1/7 ? 'PASS' : 'FAIL' }
  AAA-level large text: ${contrastRatio < 1/4.5 ? 'PASS' : 'FAIL' }
  AA-level large text: ${contrastRatio < 1/3 ? 'PASS' : 'FAIL' }
*/
const calculateContrastRatio = (bgColor: string, fgColor: string) => {
  const color1rgb = getRgbColorObject(fgColor);
  const color2rgb = getRgbColorObject(bgColor);

  // calculate the relative luminance
  const color1luminance = getLuminance(color1rgb.red, color1rgb.green, color1rgb.blue);
  const color2luminance = getLuminance(color2rgb.red, color2rgb.green, color2rgb.blue);

  // calculate the color contrast ratio
  const ratio = color1luminance > color2luminance 
    ? ((color2luminance + 0.05) / (color1luminance + 0.05))
    : ((color1luminance + 0.05) / (color2luminance + 0.05));

  return ratio;
};

interface colorContrastItemProps {
  backgroundItemClass: string, 
  foregroundItemClass: string,
  isForegroundItemBtn?: boolean
}

export const checkColorContrastAndUpdateStyle = ({ backgroundItemClass, foregroundItemClass, isForegroundItemBtn = false }: colorContrastItemProps) => {
  const backgroundItem = Array.from(document.querySelectorAll(backgroundItemClass))[0] as HTMLElement;
  const foregroundItem = Array.from(document.querySelectorAll(foregroundItemClass))[0] as HTMLElement;

  if (!backgroundItem || !foregroundItem) {
    return;
  }

  const backgroundItemColor = window.getComputedStyle(backgroundItem).getPropertyValue('background-color');
  const foregroundItemColor = isForegroundItemBtn ? window.getComputedStyle(foregroundItem).getPropertyValue('color'): window.getComputedStyle(foregroundItem).getPropertyValue('fill');

  const contrastRatio = calculateContrastRatio(backgroundItemColor, foregroundItemColor);
  if (contrastRatio >= 1/4.5) {
    if (isForegroundItemBtn) {
      foregroundItem.style.color = '#000000';
    } else {
      foregroundItem.style.filter = 'invert(1)';
    }
  }
};

export const focusTrapOptions: any = {
  checkCanFocusTrap: (trapContainers: Array<HTMLElement | SVGElement>) => {
    const results = trapContainers.map((trapContainer: HTMLElement | SVGElement) => {
      return new Promise<void>((resolve) => {
        const interval = setInterval(() => {
          if (getComputedStyle(trapContainer).visibility !== 'hidden') {
            resolve();
            clearInterval(interval);
          }
        }, 0);
      });
    });
    // Return a promise that resolves when all the trap containers are able to receive focus
    return Promise.all(results);
  }
};
