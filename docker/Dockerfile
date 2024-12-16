FROM julia:1.11

WORKDIR /app

COPY . .

RUN julia -e 'using Pkg; Pkg.add("Stressify")'

CMD ["julia", "--project=."]
