FROM scratch

COPY kedu /kedu

EXPOSE 8080

CMD ["/kedu"]
